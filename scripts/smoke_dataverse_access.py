"""P1 smoke test for Dataverse SDK reads and TDS SQL execution.

Example:
    python scripts/smoke_dataverse_access.py ^
      --table soccer=team ^
      --table california_schools=schools ^
      --table student_club=club
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from utils.dataverse_sdk import DEFAULT_DB_IDS, sdk_read_smoke  # noqa: E402
from utils.dataverse_utils import close_tds_connections, execute_sql_dataverse  # noqa: E402


def _parse_table_args(values: list[str]) -> dict[str, str]:
    tables: dict[str, str] = {}
    for value in values:
        if "=" not in value:
            raise argparse.ArgumentTypeError(
                f"Invalid --table value {value!r}; expected db_id=table_name"
            )
        db_id, table = value.split("=", 1)
        tables[db_id.strip()] = table.strip()
    return tables


def _tds_select_top_one(table: str) -> str:
    escaped = table.replace("]", "]]")
    return f"SELECT TOP 1 * FROM [{escaped}]"


def main() -> int:
    parser = argparse.ArgumentParser(description="Smoke test Dataverse SDK + TDS access")
    parser.add_argument(
        "--db-id",
        action="append",
        default=[],
        help="Dataset db_id to test. Defaults to soccer, california_schools, student_club.",
    )
    parser.add_argument(
        "--table",
        action="append",
        default=[],
        help="Smoke table mapping in db_id=table format. Required for each tested db_id.",
    )
    parser.add_argument(
        "--skip-sdk",
        action="store_true",
        help="Skip SDK simple-read smoke.",
    )
    parser.add_argument(
        "--skip-tds",
        action="store_true",
        help="Skip TDS SQL smoke.",
    )
    args = parser.parse_args()

    db_ids = args.db_id or list(DEFAULT_DB_IDS)
    tables = _parse_table_args(args.table)
    missing = [db_id for db_id in db_ids if db_id not in tables]
    if missing:
        print(
            "Missing --table mappings for: "
            + ", ".join(missing)
            + ". Example: --table soccer=team",
            file=sys.stderr,
        )
        return 2

    failures: list[str] = []
    try:
        for db_id in db_ids:
            table = tables[db_id]
            print(f"\n[{db_id}] table={table}")

            if not args.skip_sdk:
                try:
                    count = sdk_read_smoke(db_id, table)
                    print(f"  SDK read: ok ({count} row(s) in first page)")
                except Exception as exc:
                    failures.append(f"{db_id} SDK read failed: {exc}")
                    print(f"  SDK read: failed: {exc}")

            if not args.skip_tds:
                sql = _tds_select_top_one(table)
                try:
                    rows = execute_sql_dataverse(db_id, sql, timeout_seconds=30)
                    print(f"  TDS SQL: ok ({len(rows)} row(s))")
                except Exception as exc:
                    failures.append(f"{db_id} TDS SQL failed: {exc}")
                    print(f"  TDS SQL: failed: {exc}")
    finally:
        close_tds_connections()

    if failures:
        print("\nFailures:")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print("\nAll requested Dataverse smoke tests passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
