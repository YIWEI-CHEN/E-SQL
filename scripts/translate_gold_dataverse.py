"""Translate and validate soccer BIRD gold SQL against Dataverse TDS.

P3 is intentionally scoped to soccer:
    uv run --with-requirements requirements.txt python scripts\\translate_gold_dataverse.py --db-id soccer
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sqlite3
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import sqlglot
from sqlglot import exp, parse_one

from utils.dataverse_schema import load_schema_cache
from utils.dataverse_utils import execute_sql_dataverse


DEFAULT_SOURCE_DB_ID = {"soccer": "soccer_2016", "soccer_2016": "soccer_2016"}


def _normalize_identifier(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", value.lower())


def _default_bird_train_root() -> Path:
    for env_var in ("BIRD_TRAIN_PATH", "BIRD_DB_PATH"):
        value = os.environ.get(env_var)
        if value:
            path = Path(value)
            if (path / "train" / "train.json").exists():
                return path / "train"
            if (path / "train.json").exists():
                return path
    return Path("../bird_train/train")


def _sqlite_db_path(train_root: Path, source_db_id: str) -> Path:
    return train_root / "train_databases" / source_db_id / f"{source_db_id}.sqlite"


def _load_source_tables(sqlite_path: Path) -> dict[str, list[str]]:
    conn = sqlite3.connect(sqlite_path)
    try:
        tables = {}
        for (table_name,) in conn.execute("SELECT name FROM sqlite_master WHERE type='table'"):
            columns = [row[1] for row in conn.execute(f'PRAGMA table_info("{table_name}")')]
            tables[table_name] = columns
        return tables
    finally:
        conn.close()


def _build_identifier_maps(
    schema: dict[str, Any],
    source_tables: dict[str, list[str]],
) -> tuple[dict[str, str], dict[str, dict[str, str]], dict[str, str]]:
    table_map: dict[str, str] = {}
    column_map: dict[str, dict[str, str]] = {}
    dv_column_types: dict[str, str] = {}

    source_by_norm = {_normalize_identifier(name): name for name in source_tables}

    for table in schema["tables"]:
        source_name = table.get("source_table_name")
        if not source_name:
            continue
        source_real_name = source_by_norm.get(_normalize_identifier(source_name), source_name)
        table_map[_normalize_identifier(source_real_name)] = table["name"]

        dv_columns_by_norm = {
            _normalize_identifier(column["name"]): column["name"]
            for column in table["columns"]
            if not column.get("is_system")
        }
        for column in table["columns"]:
            if not column.get("is_system"):
                dv_column_types[_normalize_identifier(column["name"])] = column["data_type"]
        table_column_map: dict[str, str] = {}
        for source_col in source_tables.get(source_real_name, []):
            expected = "bird_soccer_" + source_col.lower()
            dv_name = dv_columns_by_norm.get(_normalize_identifier(expected))
            if dv_name:
                table_column_map[_normalize_identifier(source_col)] = dv_name
        column_map[_normalize_identifier(source_real_name)] = table_column_map

    return table_map, column_map, dv_column_types


def _preprocess_sqlite_sql(sql: str) -> str:
    """Normalize SQLite shorthand that TSQL/sqlglot won't legalize."""
    ident = r'(?:`[^`]+`|"[^"]+"|[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)?)'
    literal = r"(?:\d+(?:\.\d+)?|'[^']*')"

    def chained_lt(match: re.Match[str]) -> str:
        left, middle, right = match.group(1), match.group(2), match.group(3)
        return f"{middle} > {left} AND {middle} < {right}"

    sql = re.sub(fr"({literal})\s*<\s*({ident})\s*<\s*({literal})", chained_lt, sql)

    def chained_eq(match: re.Match[str]) -> str:
        left, middle, right = match.group(1), match.group(2), match.group(3)
        return f"{left} = {middle} AND {middle} = {right}"

    sql = re.sub(fr"({ident})\s*=\s*({ident})\s*=\s*({ident})", chained_eq, sql)
    return sql


def _table_aliases(expression: exp.Expression) -> dict[str, str]:
    aliases: dict[str, str] = {}
    for table in expression.find_all(exp.Table):
        source_name = table.name
        source_key = _normalize_identifier(source_name)
        aliases[_normalize_identifier(source_name)] = source_key
        if table.alias:
            aliases[_normalize_identifier(str(table.alias))] = source_key
    return aliases


def _query_source_tables(expression: exp.Expression) -> list[str]:
    seen: list[str] = []
    for table in expression.find_all(exp.Table):
        key = _normalize_identifier(table.name)
        if key not in seen:
            seen.append(key)
    return seen


def _literal_int(node: exp.Expression | None) -> int | None:
    if isinstance(node, exp.Literal) and not node.is_string:
        try:
            return int(node.this)
        except ValueError:
            return None
    return None


def _date_part_expression(date_part: str, value: exp.Expression) -> exp.Expression:
    return exp.Anonymous(this="DATEPART", expressions=[exp.Var(this=date_part), value.copy()])


def _is_aggregate(node: exp.Expression) -> bool:
    return isinstance(node, exp.AggFunc) or (
        isinstance(node, exp.Anonymous) and str(node.this).upper() in {"TOTAL"}
    )


def _columns_outside_aggregates(expression: exp.Expression) -> list[exp.Column]:
    columns: list[exp.Column] = []

    def visit(node: exp.Expression, inside_aggregate: bool = False) -> None:
        current_inside = inside_aggregate or _is_aggregate(node)
        if isinstance(node, exp.Column) and not current_inside:
            columns.append(node)
            return
        for child in node.iter_expressions():
            visit(child, current_inside)

    visit(expression)
    return columns


def _add_group_by_columns(expression: exp.Expression) -> exp.Expression:
    for select in expression.find_all(exp.Select):
        has_aggregate = any(_is_aggregate(node) for node in select.walk() if isinstance(node, exp.Expression))
        if not has_aggregate:
            continue
        columns: list[exp.Column] = []
        for projection in select.expressions:
            columns.extend(_columns_outside_aggregates(projection))
        if not columns:
            continue

        group = select.args.get("group")
        existing = {column.sql(dialect="tsql", identify=True).lower() for column in group.expressions} if group else set()
        additions = []
        for column in columns:
            key = column.sql(dialect="tsql", identify=True).lower()
            if key not in existing:
                additions.append(column.copy())
                existing.add(key)
        if additions:
            if group:
                group.set("expressions", [*group.expressions, *additions])
            else:
                select.set("group", exp.Group(expressions=additions))
    return expression


def _transform_date_functions(node: exp.Expression) -> exp.Expression:
    if isinstance(node, exp.Anonymous) and str(node.this).upper() in {"SUBSTR", "SUBSTRING"}:
        expressions = list(node.expressions)
        if len(expressions) >= 3:
            start = _literal_int(expressions[1])
            length = _literal_int(expressions[2])
            if start == 1 and length == 4:
                return _date_part_expression("year", expressions[0])
            if start in {6, 7} and length in {1, 2}:
                return _date_part_expression("month", expressions[0])
        return exp.Substring(this=expressions[0], start=expressions[1], length=expressions[2] if len(expressions) > 2 else None)

    if isinstance(node, exp.TimeToStr):
        fmt = node.args.get("format")
        value = node.this
        if isinstance(value, exp.TsOrDsToTimestamp):
            value = value.this
        if isinstance(fmt, exp.Literal):
            if fmt.this == "%Y":
                return _date_part_expression("year", value)
            if fmt.this in {"%m", "%-m"}:
                return _date_part_expression("month", value)
    return node


def _fix_tsql_string(sql: str, dv_column_types: dict[str, str]) -> str:
    sql = sql.replace("DATEPART('year',", "DATEPART(year,").replace("DATEPART('month',", "DATEPART(month,")
    sql = re.sub(r"\bTOTAL\s*\(", "SUM(", sql, flags=re.IGNORECASE)
    sql = re.sub(
        r"SELECT SUM\(CASE WHEN (?P<left>\[[^\]]+\](?:\.\[[^\]]+\])?) = "
        r"\(SELECT (?P<right>\[[^\]]+\](?:\.\[[^\]]+\])?) FROM (?P<table>\[[^\]]+\]) WHERE (?P<where>[^)]+)\) "
        r"THEN 1 ELSE 0 END\) FROM (?P<from>\[[^\]]+\])",
        r"SELECT SUM(CASE WHEN \g<left> = \g<right> THEN 1 ELSE 0 END) FROM \g<from> CROSS JOIN \g<table> WHERE \g<where>",
        sql,
        flags=re.IGNORECASE,
    )
    sql = re.sub(
        r"THEN (?P<value>\[[^\]]+\]\.\[[^\]]+\]) ELSE 0 END",
        r"THEN \g<value> ELSE NULL END",
        sql,
        flags=re.IGNORECASE,
    )
    sql = re.sub(
        r"(COUNT|SUM)\((\[[^\]]+\](?:\.\[[^\]]+\])?) = ([^)]+?)\)",
        r"SUM(CASE WHEN \2 = \3 THEN 1 ELSE 0 END)",
        sql,
        flags=re.IGNORECASE,
    )
    sql = re.sub(
        r"(\[[^\]]+\](?:\.\[[^\]]+\])?) BETWEEN '(\d{4})%' AND '(\d{4})%'",
        r"DATEPART(year, \1) BETWEEN \2 AND \3",
        sql,
        flags=re.IGNORECASE,
    )

    def replace_sum(match: re.Match[str]) -> str:
        column = match.group(1)
        column_name = column.split(".")[-1].strip("[]")
        data_type = dv_column_types.get(_normalize_identifier(column_name), "")
        if data_type in {"nvarchar", "varchar", "nchar", "char", "text", "ntext"}:
            return f"COUNT({column})"
        return match.group(0)

    return re.sub(r"SUM\((\[[^\]]+\](?:\.\[[^\]]+\])?)\)", replace_sum, sql, flags=re.IGNORECASE)


def translate_sql(sql: str, table_map: dict[str, str], column_map: dict[str, dict[str, str]], dv_column_types: dict[str, str]) -> str:
    expression = parse_one(_preprocess_sqlite_sql(sql), read="sqlite")
    aliases = _table_aliases(expression)
    query_tables = _query_source_tables(expression)

    def rewrite_identifiers(node: exp.Expression) -> exp.Expression:
        if isinstance(node, exp.Table):
            source_key = _normalize_identifier(node.name)
            dv_name = table_map.get(source_key)
            if dv_name:
                node.set("this", exp.to_identifier(dv_name, quoted=True))
            return node

        if isinstance(node, exp.Column):
            column_key = _normalize_identifier(node.name)
            table_ref = node.table
            source_table_key = aliases.get(_normalize_identifier(table_ref)) if table_ref else None
            dv_column = None
            if source_table_key:
                dv_column = column_map.get(source_table_key, {}).get(column_key)
            else:
                matches = [
                    cols[column_key]
                    for source_table in query_tables
                    for cols in [column_map.get(source_table, {})]
                    if column_key in cols
                ]
                if len(set(matches)) == 1:
                    dv_column = matches[0]
            if dv_column:
                node.set("this", exp.to_identifier(dv_column, quoted=True))
            return node

        return node

    expression = expression.transform(rewrite_identifiers)
    expression = expression.transform(_transform_date_functions)
    expression = _add_group_by_columns(expression)
    translated = expression.sql(dialect="tsql", identify=True)
    return _fix_tsql_string(translated, dv_column_types)


def _load_soccer_items(train_root: Path, source_db_id: str) -> list[tuple[int, dict[str, Any]]]:
    train = json.loads((train_root / "train.json").read_text(encoding="utf-8"))
    return [(idx, item) for idx, item in enumerate(train) if item.get("db_id") == source_db_id]


def main() -> int:
    parser = argparse.ArgumentParser(description="Translate and validate soccer gold SQL for Dataverse")
    parser.add_argument("--db-id", default="soccer", help="Dataverse dataset id. P3 currently supports soccer.")
    parser.add_argument("--source-db-id", default=None, help="Source BIRD db_id. Defaults to soccer_2016.")
    parser.add_argument("--bird-train-root", default=None, help="Path containing train.json and train_databases/.")
    parser.add_argument("--output-dir", default="dataverse/gold_translated")
    parser.add_argument("--limit", type=int, default=0, help="Limit number of soccer questions (0 = all).")
    parser.add_argument("--no-execute", action="store_true", help="Only translate; do not execute against Dataverse.")
    args = parser.parse_args()

    if args.db_id not in {"soccer", "soccer_2016"}:
        raise ValueError("P3 implementation is intentionally scoped to soccer / soccer_2016")

    source_db_id = args.source_db_id or DEFAULT_SOURCE_DB_ID[args.db_id]
    train_root = Path(args.bird_train_root) if args.bird_train_root else _default_bird_train_root()
    sqlite_path = _sqlite_db_path(train_root, source_db_id)
    schema = load_schema_cache("soccer")
    source_tables = _load_source_tables(sqlite_path)
    table_map, column_map, dv_column_types = _build_identifier_maps(schema, source_tables)
    items = _load_soccer_items(train_root, source_db_id)
    if args.limit > 0:
        items = items[: args.limit]

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    cache: dict[str, Any] = {}
    failures: dict[str, Any] = {}
    sql_lines: list[str] = []
    ok_count = 0

    for positional_id, (source_index, item) in enumerate(items):
        sqlite_sql = item["SQL"]
        entry = {
            "source_index": source_index,
            "question_id": positional_id,
            "source_db_id": source_db_id,
            "question": item.get("question"),
            "sqlite": sqlite_sql,
            "dataverse": "",
            "exec_ok": False,
            "exec_err": "",
            "row_count": None,
        }
        try:
            dataverse_sql = translate_sql(sqlite_sql, table_map, column_map, dv_column_types)
            entry["dataverse"] = dataverse_sql
            sql_lines.append(f"-- question_id={positional_id} source_index={source_index}\n{dataverse_sql};")
            if args.no_execute:
                entry["exec_ok"] = None
            else:
                rows = execute_sql_dataverse("soccer", dataverse_sql, timeout_seconds=30)
                entry["exec_ok"] = True
                entry["row_count"] = len(rows)
                ok_count += 1
        except Exception as exc:
            entry["exec_err"] = str(exc)
            failures[str(positional_id)] = entry
        cache[str(positional_id)] = entry

        status = "ok" if entry["exec_ok"] else "fail"
        print(f"[{positional_id + 1}/{len(items)}] qid={positional_id} source={source_index} {status}")

    out_json = output_dir / "soccer.json"
    out_sql = output_dir / "soccer.sql"
    out_failures = output_dir / "soccer_failures.json"
    out_json.write_text(json.dumps(cache, indent=2, ensure_ascii=False), encoding="utf-8")
    out_sql.write_text("\n\n".join(sql_lines) + "\n", encoding="utf-8")
    out_failures.write_text(json.dumps(failures, indent=2, ensure_ascii=False), encoding="utf-8")

    executed_count = len(items) if not args.no_execute else 0
    print("\nP3 soccer gold translation complete")
    print(f"Translated: {len(items)}")
    if not args.no_execute:
        print(f"Execution OK: {ok_count}/{executed_count} ({ok_count / executed_count * 100:.2f}%)")
        print(f"Failures: {len(failures)}")
    print(f"Wrote: {out_json}")
    print(f"Wrote: {out_sql}")
    print(f"Wrote: {out_failures}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
