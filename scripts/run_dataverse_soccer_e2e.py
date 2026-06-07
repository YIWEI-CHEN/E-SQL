"""P4/P5 Dataverse-native soccer E-SQL runner.

This runner is intentionally soccer-scoped. It asks the LLM to generate
Dataverse T-SQL directly, executes candidate/refined SQL through Dataverse TDS,
scores both candidate and final SQL against the P3 Dataverse gold cache, and
supports resume/retry for full soccer experiments.
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


def _few_shot_examples_from_file(path: Path, current_qid: int, count: int) -> str:
    if count <= 0:
        return ""
    examples_data = json.loads(path.read_text(encoding="utf-8"))
    examples = []
    for item in examples_data:
        if item.get("question_id") == current_qid:
            continue
        examples.append(
            "Question: {question}\nDataverse T-SQL: {sql}".format(
                question=item.get("question", ""),
                sql=item["dataverse_sql"],
            )
        )
        if len(examples) >= count:
            break
    return "\n### Examples\n" + "\n\n".join(examples) + "\n" if examples else ""


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


def _load_existing_predictions(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return []
    return data if isinstance(data, list) else []


def _should_skip_existing(record: dict[str, Any], retry_failed: bool) -> bool:
    if retry_failed:
        return bool(record.get("results", {}).get("exec_res"))
    return True


def _sum_usage(records: list[dict[str, Any]], field: str) -> dict[str, int]:
    totals = {"prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0}
    for record in records:
        usage = record.get(field) or {}
        for key in totals:
            totals[key] += int(usage.get(key) or 0)
    return totals


def _write_report(output_dir: Path, metrics: dict[str, Any], records: list[dict[str, Any]]) -> None:
    failures = [record for record in records if not record.get("results", {}).get("exec_res")]
    lines = [
        "# Dataverse Soccer P5 Report",
        "",
        f"- Total: {metrics['total_correct_count']}/{metrics['total_item_count']}",
        f"- EX: {metrics['EX']:.2f}%" if metrics["EX"] is not None else "- EX: n/a",
        f"- Candidate EX: {metrics['candidate_EX']:.2f}%" if metrics["candidate_EX"] is not None else "- Candidate EX: n/a",
        f"- Failures: {len(failures)}",
        f"- Candidate tokens: {metrics['candidate_usage']['total_tokens']}",
        f"- Refinement tokens: {metrics['refinement_usage']['total_tokens']}",
        "",
    ]
    if failures:
        lines.extend(["## Failures", ""])
        for record in failures:
            lines.extend(
                [
                    f"### qid={record['question_id']} source={record['source_index']}",
                    "",
                    record.get("question", ""),
                    "",
                    f"Error: `{record.get('results', {}).get('exec_err', '')}`",
                    "",
                    "```sql",
                    record.get("predicted_sql", ""),
                    "```",
                    "",
                ]
            )
    (output_dir / "report.md").write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Run a Dataverse-native soccer E-SQL experiment")
    parser.add_argument("--model", default="gpt-4.1")
    parser.add_argument("--temperature", type=float, default=0.0)
    parser.add_argument("--top_p", type=float, default=1.0)
    parser.add_argument("--max_tokens", type=int, default=4096)
    parser.add_argument("--limit", type=int, default=5, help="Number of soccer questions to run. Use 0 for all.")
    parser.add_argument("--start", type=int, default=0)
    parser.add_argument("--few-shot", type=int, default=3)
    parser.add_argument("--few-shot-file", default=None, help="Optional reusable Dataverse few-shot JSON file.")
    parser.add_argument("--bird-train-root", default=None)
    parser.add_argument("--dry-run", action="store_true", help="Build prompts and output files without calling the LLM.")
    parser.add_argument("--output-dir", default=None)
    parser.add_argument("--overwrite", action="store_true", help="Ignore existing predictions and rerun selected questions.")
    parser.add_argument("--retry-failed", action="store_true", help="With existing predictions, rerun only failed questions.")
    parser.add_argument("--save-prompts", action="store_true", help="Store full prompts in predictions.json.")
    args = parser.parse_args()

    load_dotenv()
    random.seed(42)

    train_root = Path(args.bird_train_root) if args.bird_train_root else _default_bird_train_root()
    dataset = _load_soccer_dataset(train_root)
    end = None if args.limit == 0 else args.start + args.limit
    selected = dataset[args.start : end]
    if not selected:
        raise RuntimeError("No soccer questions selected")

    schema_text = _read(Path("dataverse/schema_cache/soccer.schema.sql"))
    gold_cache = json.loads(Path("dataverse/gold_translated/soccer.json").read_text(encoding="utf-8"))
    candidate_template = _read(Path("prompt_templates/candidate_sql_generation_prompt_template_dataverse.txt"))
    refinement_template = _read(Path("prompt_templates/sql_refinement_prompt_template_dataverse.txt"))

    output_dir = Path(args.output_dir or f"results/dataverse_soccer_p4_azure_{args.model}")
    output_dir.mkdir(parents=True, exist_ok=True)
    predictions_path = output_dir / "predictions.json"

    predictions = [] if args.overwrite else _load_existing_predictions(predictions_path)
    prediction_by_qid = {int(record["question_id"]): record for record in predictions if "question_id" in record}

    for qid, (source_index, item) in enumerate(selected, start=args.start):
        existing = prediction_by_qid.get(qid)
        if existing and _should_skip_existing(existing, retry_failed=args.retry_failed):
            print(f"[{qid}] skip existing correctness={existing.get('results', {}).get('exec_res')}")
            continue

        question = item["question"]
        evidence = item.get("evidence") or ""
        if args.few_shot_file:
            examples = _few_shot_examples_from_file(Path(args.few_shot_file), qid, args.few_shot)
        else:
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
            "candidate_prompt": candidate_prompt if (args.dry_run or args.save_prompts) else None,
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
        candidate_compare = compare_sqls_dataverse(
            db_id="soccer",
            predicted_sql=possible_sql,
            ground_truth_sql=record["gold_dataverse_sql"],
        )

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

        record.update(
            {
                "candidate_sql": possible_sql,
                "candidate_exec_err": exec_err,
                "candidate_results": candidate_compare,
                "predicted_sql": predicted_sql,
                "results": compare,
                "candidate_usage": candidate_usage,
                "refinement_usage": refined_usage,
            }
        )
        prediction_by_qid[qid] = record
        predictions = [prediction_by_qid[key] for key in sorted(prediction_by_qid)]
        predictions_path.write_text(json.dumps(predictions, indent=2, default=str), encoding="utf-8")
        print(f"[{qid}] correctness={compare['exec_res']} err={compare['exec_err']}")

    selected_qids = {qid for qid, _ in enumerate(selected, start=args.start)}
    selected_predictions = [record for record in predictions if int(record.get("question_id", -1)) in selected_qids and not record.get("dry_run")]
    correct = sum(1 for record in selected_predictions if record.get("results", {}).get("exec_res"))
    candidate_correct = sum(1 for record in selected_predictions if record.get("candidate_results", {}).get("exec_res"))
    total = len(selected_predictions)
    metrics = {
        "exec_engine": "dataverse",
        "db_id": "soccer",
        "total_item_count": total,
        "total_correct_count": correct,
        "EX": (correct / total * 100) if total else None,
        "candidate_correct_count": candidate_correct,
        "candidate_EX": (candidate_correct / total * 100) if total else None,
        "candidate_usage": _sum_usage(selected_predictions, "candidate_usage"),
        "refinement_usage": _sum_usage(selected_predictions, "refinement_usage"),
        "config": vars(args),
    }
    predictions_path.write_text(json.dumps(predictions, indent=2, default=str), encoding="utf-8")
    Path(output_dir / "metrics.json").write_text(json.dumps(metrics, indent=2, default=str), encoding="utf-8")
    _write_report(output_dir, metrics, selected_predictions)
    print(f"Wrote {predictions_path}")
    print(f"Wrote {output_dir / 'metrics.json'}")
    print(f"Wrote {output_dir / 'report.md'}")
    if total:
        print(f"EX={metrics['EX']:.2f}% ({correct}/{total})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
