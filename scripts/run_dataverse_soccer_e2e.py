"""P4 Dataverse-native soccer E-SQL smoke runner.

This runner is intentionally soccer-scoped. It asks the LLM to generate
Dataverse T-SQL directly, executes candidate/refined SQL through Dataverse TDS,
and scores the final SQL against the P3 Dataverse gold cache.
"""

from __future__ import annotations

import argparse
import json
import os
import random
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from dotenv import load_dotenv

from utils.dataverse_llm import create_dataverse_response
from utils.dataverse_utils import compare_sqls_dataverse, execute_sql_dataverse


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


def _load_soccer_dataset(train_root: Path) -> list[tuple[int, dict[str, Any]]]:
    full = json.loads((train_root / "train.json").read_text(encoding="utf-8"))
    return [(idx, item) for idx, item in enumerate(full) if item.get("db_id") == "soccer_2016"]


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _json_content(response: Any) -> dict[str, Any]:
    content = response.choices[0].message.content
    if isinstance(content, dict):
        return content
    content = re.sub(r"^```(?:json)?\s*", "", content.strip())
    content = re.sub(r"\s*```$", "", content)
    return json.loads(content)


def _usage(response: Any) -> dict[str, int]:
    usage = getattr(response, "usage", None)
    return {
        "prompt_tokens": getattr(usage, "prompt_tokens", 0) if usage else 0,
        "completion_tokens": getattr(usage, "completion_tokens", 0) if usage else 0,
        "total_tokens": getattr(usage, "total_tokens", 0) if usage else 0,
    }


def _fill_common(template: str, **values: str) -> str:
    defaults = {
        "FEWSHOT_EXAMPLES": "",
        "SCHEMA": "",
        "DB_DESCRIPTIONS": "",
        "DB_SAMPLES": "",
        "QUESTION": "",
        "EVIDENCE": "",
        "POSSIBLE_CONDITIONS": "",
        "POSSIBLE_SQL_Query": "",
        "EXECUTION_ERROR": "",
    }
    defaults.update(values)
    prompt = template.format(**defaults)
    return prompt.replace("```json{", "{").replace("}```", "}").replace("{{", "{").replace("}}", "}")


def _section(title: str, text: str | None) -> str:
    if not text:
        return ""
    return f"\n### {title}\n{text}\n"


def _few_shot_examples(gold_cache: dict[str, Any], current_qid: int, count: int) -> str:
    if count <= 0:
        return ""
    examples = []
    for key in sorted(gold_cache, key=lambda value: int(value)):
        if int(key) == current_qid:
            continue
        entry = gold_cache[key]
        if not entry.get("exec_ok"):
            continue
        examples.append(
            "Question: {question}\nDataverse T-SQL: {sql}".format(
                question=entry.get("question", ""),
                sql=entry["dataverse"],
            )
        )
        if len(examples) >= count:
            break
    if not examples:
        return ""
    return "\n### Examples\n" + "\n\n".join(examples) + "\n"


def _gold_for_qid(gold_cache: dict[str, Any], qid: int) -> str:
    return gold_cache[str(qid)]["dataverse"]


def _run_generation(
    *,
    stage: str,
    prompt: str,
    args: argparse.Namespace,
) -> tuple[dict[str, Any], dict[str, int]]:
    response = create_dataverse_response(
        stage=stage,
        prompt=prompt,
        model=args.model,
        max_tokens=args.max_tokens,
        temperature=args.temperature,
        top_p=args.top_p,
        n=1,
    )
    return _json_content(response), _usage(response)


def main() -> int:
    parser = argparse.ArgumentParser(description="Run a Dataverse-native soccer E-SQL smoke experiment")
    parser.add_argument("--model", default="gpt-4.1")
    parser.add_argument("--temperature", type=float, default=0.0)
    parser.add_argument("--top_p", type=float, default=1.0)
    parser.add_argument("--max_tokens", type=int, default=4096)
    parser.add_argument("--limit", type=int, default=5)
    parser.add_argument("--start", type=int, default=0)
    parser.add_argument("--few-shot", type=int, default=3)
    parser.add_argument("--bird-train-root", default=None)
    parser.add_argument("--dry-run", action="store_true", help="Build prompts and output files without calling the LLM.")
    parser.add_argument("--output-dir", default=None)
    args = parser.parse_args()

    load_dotenv()
    random.seed(42)

    train_root = Path(args.bird_train_root) if args.bird_train_root else _default_bird_train_root()
    dataset = _load_soccer_dataset(train_root)
    selected = dataset[args.start : args.start + args.limit]
    if not selected:
        raise RuntimeError("No soccer questions selected")

    schema_text = _read(Path("dataverse/schema_cache/soccer.schema.sql"))
    gold_cache = json.loads(Path("dataverse/gold_translated/soccer.json").read_text(encoding="utf-8"))
    candidate_template = _read(Path("prompt_templates/candidate_sql_generation_prompt_template_dataverse.txt"))
    refinement_template = _read(Path("prompt_templates/sql_refinement_prompt_template_dataverse.txt"))

    output_dir = Path(args.output_dir or f"results/dataverse_soccer_p4_azure_{args.model}")
    output_dir.mkdir(parents=True, exist_ok=True)

    predictions = []
    correct = 0

    for qid, (source_index, item) in enumerate(selected, start=args.start):
        question = item["question"]
        evidence = item.get("evidence") or ""
        examples = _few_shot_examples(gold_cache, qid, args.few_shot)
        common = {
            "FEWSHOT_EXAMPLES": examples,
            "SCHEMA": _section("Database Schema", schema_text),
            "DB_DESCRIPTIONS": _section("Database Column Descriptions", "Use the Dataverse table and column names from the schema."),
            "DB_SAMPLES": _section("Database Samples", "No sample values are injected in P4 smoke mode."),
            "QUESTION": _section("Question", question),
            "EVIDENCE": _section("Evidence", evidence or "No evidence."),
        }
        candidate_prompt = _fill_common(candidate_template, **common)
        record: dict[str, Any] = {
            "question_id": qid,
            "source_index": source_index,
            "question": question,
            "evidence": evidence,
            "gold_dataverse_sql": _gold_for_qid(gold_cache, qid),
            "candidate_prompt": candidate_prompt if args.dry_run else None,
        }

        if args.dry_run:
            record["dry_run"] = True
            predictions.append(record)
            print(f"[{qid}] dry-run prompt built")
            continue

        candidate_obj, candidate_usage = _run_generation(
            stage="candidate_sql_generation",
            prompt=candidate_prompt,
            args=args,
        )
        possible_sql = candidate_obj.get("SQL", "")
        exec_err = ""
        try:
            execute_sql_dataverse("soccer", possible_sql, timeout_seconds=30)
        except Exception as exc:
            exec_err = str(exc)

        refinement_prompt = _fill_common(
            refinement_template,
            **common,
            POSSIBLE_SQL_Query=_section("Possible Dataverse T-SQL Query", possible_sql),
            EXECUTION_ERROR=_section("Execution Error", exec_err) if exec_err else "",
            POSSIBLE_CONDITIONS="",
        )
        refined_obj, refined_usage = _run_generation(
            stage="sql_refinement",
            prompt=refinement_prompt,
            args=args,
        )
        predicted_sql = refined_obj.get("SQL", "")
        compare = compare_sqls_dataverse(
            db_id="soccer",
            predicted_sql=predicted_sql,
            ground_truth_sql=record["gold_dataverse_sql"],
        )
        if compare["exec_res"]:
            correct += 1

        record.update(
            {
                "candidate_sql": possible_sql,
                "candidate_exec_err": exec_err,
                "predicted_sql": predicted_sql,
                "results": compare,
                "candidate_usage": candidate_usage,
                "refinement_usage": refined_usage,
            }
        )
        predictions.append(record)
        Path(output_dir / "predictions.json").write_text(json.dumps(predictions, indent=2, default=str), encoding="utf-8")
        print(f"[{qid}] correctness={compare['exec_res']} err={compare['exec_err']}")

    metrics = {
        "exec_engine": "dataverse",
        "db_id": "soccer",
        "total_item_count": len(selected),
        "total_correct_count": correct,
        "EX": (correct / len(selected) * 100) if selected and not args.dry_run else None,
        "config": vars(args),
    }
    Path(output_dir / "predictions.json").write_text(json.dumps(predictions, indent=2, default=str), encoding="utf-8")
    Path(output_dir / "metrics.json").write_text(json.dumps(metrics, indent=2, default=str), encoding="utf-8")
    print(f"Wrote {output_dir / 'predictions.json'}")
    print(f"Wrote {output_dir / 'metrics.json'}")
    if not args.dry_run:
        print(f"EX={metrics['EX']:.2f}% ({correct}/{len(selected)})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
