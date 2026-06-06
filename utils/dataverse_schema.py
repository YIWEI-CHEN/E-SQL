"""Dataverse schema cache and prompt-schema rendering utilities."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from utils.dataverse_utils import execute_sql_dataverse_records


SCHEMA_CACHE_DIR = Path("dataverse") / "schema_cache"

DEFAULT_TABLE_PREFIX_BY_DB_ID = {
    "soccer": "bird_soccer_",
    "soccer_2016": "bird_soccer_",
}

SYSTEM_COLUMN_NAMES = {
    "createdby",
    "createdbyname",
    "createdbyyominame",
    "createdon",
    "createdonbehalfby",
    "createdonbehalfbyname",
    "createdonbehalfbyyominame",
    "importsequencenumber",
    "modifiedby",
    "modifiedbyname",
    "modifiedbyyominame",
    "modifiedon",
    "modifiedonbehalfby",
    "modifiedonbehalfbyname",
    "modifiedonbehalfbyyominame",
    "organizationid",
    "organizationidname",
    "overriddencreatedon",
    "ownerid",
    "owneridname",
    "owneridtype",
    "owneridyominame",
    "owningbusinessunit",
    "owningbusinessunitname",
    "owningteam",
    "owninguser",
    "statecode",
    "statecodename",
    "statuscode",
    "statuscodename",
    "timezoneruleversionnumber",
    "utcconversiontimezonecode",
    "versionnumber",
}


@dataclass(frozen=True)
class DataverseColumn:
    name: str
    data_type: str
    max_length: int | None
    precision: int | None
    scale: int | None
    is_nullable: bool
    is_primary_key: bool
    is_system: bool


@dataclass(frozen=True)
class DataverseTable:
    name: str
    source_table_name: str | None
    columns: list[DataverseColumn]


def _to_int(value: Any) -> int | None:
    if value in (None, ""):
        return None
    return int(value)


def _to_bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value != 0
    return str(value).lower() in {"1", "true", "yes"}


def _source_table_name(table_name: str, table_prefix: str | None) -> str | None:
    if not table_prefix or not table_name.startswith(table_prefix):
        return None
    suffix = table_name[len(table_prefix):]
    return "_".join(part.capitalize() for part in suffix.split("_"))


def _like_escape(value: str) -> str:
    return value.replace("'", "''").replace("[", "[[]").replace("%", "[%]").replace("_", "[_]")


def fetch_dataverse_schema(db_id: str, table_prefix: str | None = None) -> dict[str, Any]:
    """Fetch table/column metadata from Dataverse TDS sys catalog views."""
    table_prefix = table_prefix if table_prefix is not None else DEFAULT_TABLE_PREFIX_BY_DB_ID.get(db_id)
    where_clause = ""
    if table_prefix:
        where_clause = f"WHERE t.name LIKE '{_like_escape(table_prefix)}%'"

    sql = f"""
SELECT
    t.name AS table_name,
    c.column_id AS column_id,
    c.name AS column_name,
    ty.name AS data_type,
    c.max_length AS max_length,
    c.precision AS precision,
    c.scale AS scale,
    c.is_nullable AS is_nullable,
    CASE WHEN pk.column_id IS NULL THEN 0 ELSE 1 END AS is_primary_key
FROM sys.tables AS t
INNER JOIN sys.columns AS c ON c.object_id = t.object_id
INNER JOIN sys.types AS ty ON ty.user_type_id = c.user_type_id
LEFT JOIN (
    SELECT ic.object_id, ic.column_id
    FROM sys.indexes AS i
    INNER JOIN sys.index_columns AS ic
        ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    WHERE i.is_primary_key = 1
) AS pk ON pk.object_id = c.object_id AND pk.column_id = c.column_id
{where_clause}
ORDER BY t.name, c.column_id
"""
    rows = execute_sql_dataverse_records(db_id, sql, timeout_seconds=60)

    relationship_where_clause = ""
    if table_prefix:
        relationship_where_clause = f"WHERE pt.name LIKE '{_like_escape(table_prefix)}%'"
    relationship_sql = f"""
SELECT
    fk.name AS relationship_name,
    pt.name AS parent_table,
    pc.name AS parent_column,
    rt.name AS referenced_table,
    rc.name AS referenced_column
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables AS pt ON pt.object_id = fk.parent_object_id
INNER JOIN sys.columns AS pc
    ON pc.object_id = fkc.parent_object_id AND pc.column_id = fkc.parent_column_id
INNER JOIN sys.tables AS rt ON rt.object_id = fk.referenced_object_id
INNER JOIN sys.columns AS rc
    ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
{relationship_where_clause}
ORDER BY pt.name, pc.name
"""
    relationship_rows = execute_sql_dataverse_records(db_id, relationship_sql, timeout_seconds=60)

    tables: dict[str, DataverseTable] = {}
    for row in rows:
        table_name = row["table_name"]
        column_name = row["column_name"]
        table = tables.get(table_name)
        if table is None:
            table = DataverseTable(
                name=table_name,
                source_table_name=_source_table_name(table_name, table_prefix),
                columns=[],
            )
            tables[table_name] = table

        table.columns.append(
            DataverseColumn(
                name=column_name,
                data_type=row["data_type"],
                max_length=_to_int(row.get("max_length")),
                precision=_to_int(row.get("precision")),
                scale=_to_int(row.get("scale")),
                is_nullable=_to_bool(row.get("is_nullable")),
                is_primary_key=_to_bool(row.get("is_primary_key")),
                is_system=column_name.lower() in SYSTEM_COLUMN_NAMES,
            )
        )

    return {
        "db_id": db_id,
        "table_prefix": table_prefix,
        "relationships": [
            {
                "name": row["relationship_name"],
                "parent_table": row["parent_table"],
                "parent_column": row["parent_column"],
                "referenced_table": row["referenced_table"],
                "referenced_column": row["referenced_column"],
            }
            for row in relationship_rows
            if not str(row["parent_column"]).lower() in SYSTEM_COLUMN_NAMES
        ],
        "tables": [
            {
                "name": table.name,
                "source_table_name": table.source_table_name,
                "columns": [
                    {
                        "name": column.name,
                        "data_type": column.data_type,
                        "max_length": column.max_length,
                        "precision": column.precision,
                        "scale": column.scale,
                        "is_nullable": column.is_nullable,
                        "is_primary_key": column.is_primary_key,
                        "is_system": column.is_system,
                    }
                    for column in table.columns
                ],
            }
            for table in tables.values()
        ],
    }


def write_schema_cache(schema: dict[str, Any], output_path: Path | None = None) -> Path:
    """Write schema JSON cache and return its path."""
    db_id = schema["db_id"]
    output_path = output_path or SCHEMA_CACHE_DIR / f"{db_id}.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(schema, indent=2), encoding="utf-8")
    return output_path


def load_schema_cache(db_id: str, cache_path: Path | None = None) -> dict[str, Any]:
    path = cache_path or SCHEMA_CACHE_DIR / f"{db_id}.json"
    return json.loads(path.read_text(encoding="utf-8"))


def _format_type(column: dict[str, Any]) -> str:
    data_type = column["data_type"]
    max_length = column.get("max_length")
    precision = column.get("precision")
    scale = column.get("scale")

    if data_type in {"nvarchar", "varchar", "nchar", "char"} and max_length:
        if int(max_length) == -1:
            return f"{data_type}(max)"
        length = int(max_length)
        if data_type.startswith("n"):
            length = max(1, length // 2)
        return f"{data_type}({length})"
    if data_type in {"decimal", "numeric"} and precision is not None and scale is not None:
        return f"{data_type}({precision},{scale})"
    return data_type


def render_schema_for_prompt(
    schema: dict[str, Any],
    include_system_columns: bool = False,
    include_source_mapping: bool = True,
) -> str:
    """Render cached Dataverse schema as T-SQL CREATE TABLE statements."""
    statements: list[str] = []
    relationship_by_column = {
        (relationship["parent_table"], relationship["parent_column"]): relationship
        for relationship in schema.get("relationships", [])
    }
    for table in schema.get("tables", []):
        header = f"CREATE TABLE [{table['name']}] ("
        lines = []
        for column in table.get("columns", []):
            if column.get("is_system") and not include_system_columns:
                continue
            parts = [f"[{column['name']}]", _format_type(column)]
            if column.get("is_primary_key"):
                parts.append("PRIMARY KEY")
            elif not column.get("is_nullable"):
                parts.append("NOT NULL")
            line = "  " + " ".join(parts)
            relationship = relationship_by_column.get((table["name"], column["name"]))
            if relationship:
                line += (
                    " /* lookup -> "
                    f"[{relationship['referenced_table']}]"
                    f"([{relationship['referenced_column']}])"
                    " */"
                )
            lines.append(line)

        if not lines:
            continue

        body = ",\n".join(lines)
        statement = f"{header}\n{body}\n)"
        if include_source_mapping and table.get("source_table_name"):
            statement = f"-- Source SQLite table: {table['source_table_name']}\n{statement}"
        statements.append(statement)

    return "\n\n".join(statements)
