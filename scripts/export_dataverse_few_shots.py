"""Export reusable Dataverse few-shot examples from the P3 gold cache."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


PATTERN_KEYWORDS = {
    "join": "JOIN",
    "group_by": "GROUP BY",
    "top": "TOP ",
    "date": "DATEPART",
    "case": "CASE WHEN",
    "subquery": "SELECT TOP 1",
    "aggregate": "SUM(",
}


def _pattern_tags(sql: str) -> list[str]:
    upper = sql.upper()
    return [name for name, keyword in PATTERN_KEYWORDS.items() if keyword in upper]


def main() -> int:
    parser = argparse.ArgumentParser(description="Export soccer Dataverse few-shot examples")
    parser.add_argument("--gold-cache", default="dataverse/gold_translated/soccer.json")
    parser.add_argument("--output", default="few-shot-data/sql_generation_dataverse_soccer.json")
    parser.add_argument("--count", type=int, default=40)
    args = parser.parse_args()

    cache = json.loads(Path(args.gold_cache).read_text(encoding="utf-8"))
    selected = []
    covered_patterns: set[str] = set()

    entries = [cache[key] for key in sorted(cache, key=lambda value: int(value))]
    for entry in entries:
        if not entry.get("exec_ok"):
            continue
        tags = _pattern_tags(entry["dataverse"])
        if not tags:
            tags = ["simple"]
        if len(selected) < args.count and (set(tags) - covered_patterns or len(selected) < 10):
            selected.append(
                {
                    "question_id": entry["question_id"],
                    "source_index": entry["source_index"],
                    "question": entry["question"],
                    "sqlite_sql": entry["sqlite"],
                    "dataverse_sql": entry["dataverse"],
                    "patterns": tags,
                }
            )
            covered_patterns.update(tags)
        if len(selected) >= args.count and len(covered_patterns) >= len(PATTERN_KEYWORDS):
            break

    # Fill remaining slots deterministically if pattern-first selection did not reach count.
    selected_ids = {item["question_id"] for item in selected}
    for entry in entries:
        if len(selected) >= args.count:
            break
        if not entry.get("exec_ok") or entry["question_id"] in selected_ids:
            continue
        selected.append(
            {
                "question_id": entry["question_id"],
                "source_index": entry["source_index"],
                "question": entry["question"],
                "sqlite_sql": entry["sqlite"],
                "dataverse_sql": entry["dataverse"],
                "patterns": _pattern_tags(entry["dataverse"]) or ["simple"],
            }
        )
        selected_ids.add(entry["question_id"])

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(selected, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {output} ({len(selected)} examples)")
    print("Patterns:", ", ".join(sorted({tag for item in selected for tag in item["patterns"]})))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
