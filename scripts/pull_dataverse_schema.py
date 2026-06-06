"""Pull and render Dataverse schema metadata for a dataset.

P2 currently targets the soccer dataset:
    uv run --with-requirements requirements.txt python scripts\\pull_dataverse_schema.py --db-id soccer
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from utils.dataverse_schema import (  # noqa: E402
    fetch_dataverse_schema,
    render_schema_for_prompt,
    write_schema_cache,
)


def main() -> int:
    parser = argparse.ArgumentParser(description="Pull Dataverse schema metadata into a local cache")
    parser.add_argument("--db-id", default="soccer", help="Dataset id. P2 currently supports soccer.")
    parser.add_argument(
        "--table-prefix",
        default=None,
        help="Dataverse table prefix to include. Defaults to bird_soccer_ for soccer.",
    )
    parser.add_argument(
        "--render-output",
        default=None,
        help="Optional path to write prompt-rendered schema text.",
    )
    args = parser.parse_args()

    if args.db_id not in {"soccer", "soccer_2016"}:
        raise ValueError("P2 implementation is intentionally scoped to soccer / soccer_2016")

    schema = fetch_dataverse_schema(args.db_id, table_prefix=args.table_prefix)
    if not schema.get("tables"):
        raise RuntimeError("No Dataverse tables found for the requested dataset/prefix")

    cache_path = write_schema_cache(schema)
    rendered = render_schema_for_prompt(schema)
    if not rendered.strip():
        raise RuntimeError("Rendered schema is empty")

    render_output = Path(args.render_output) if args.render_output else cache_path.with_suffix(".schema.sql")
    render_output.write_text(rendered, encoding="utf-8")

    table_count = len(schema["tables"])
    column_count = sum(len(table["columns"]) for table in schema["tables"])
    visible_column_count = sum(
        1
        for table in schema["tables"]
        for column in table["columns"]
        if not column.get("is_system")
    )
    print(f"Wrote schema cache: {cache_path}")
    print(f"Wrote rendered schema: {render_output}")
    print(f"Tables: {table_count}; columns: {column_count}; prompt-visible columns: {visible_column_count}")
    print("First tables:")
    for table in schema["tables"][:10]:
        print(f"  - {table['name']} ({len(table['columns'])} columns)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
