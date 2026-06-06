"""Dataverse TDS SQL execution helpers for execution-accuracy scoring.

This module uses the same execution path as the dv-sql skill: Azure CLI token
acquisition plus PowerShell Invoke-Sqlcmd. In this environment it is more
reliable against Dataverse TDS than pyodbc access-token auth.
"""

from __future__ import annotations

import logging
import os
import shutil
import subprocess
import csv
import io
from datetime import date, datetime, time
from decimal import Decimal
from typing import Any, Dict, Optional, Union

from dotenv import load_dotenv

from utils.dataverse_sdk import get_access_token, get_dataverse_host


def _ps_single_quoted(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def _invoke_sqlcmd(db_id: str, sql: str, timeout_seconds: Optional[int] = 30) -> list[dict[str, Any]]:
    host = get_dataverse_host(db_id)
    load_dotenv()

    resource = os.environ.get("DATAVERSE_TDS_RESOURCE", f"https://{host}")
    token_source = os.environ.get("DATAVERSE_TDS_TOKEN_SOURCE", "sdk").lower()
    if token_source == "sdk":
        token = get_access_token(db_id, scope=f"{resource.rstrip('/')}/.default")
    elif token_source == "az":
        az_exe = shutil.which("az") or shutil.which("az.cmd")
        if not az_exe:
            raise RuntimeError("Azure CLI executable was not found on PATH")
        token_cmd = [
            az_exe,
            "account",
            "get-access-token",
            "--resource",
            resource,
            "--query",
            "accessToken",
            "-o",
            "tsv",
        ]
        dataverse_tenant_id = os.environ.get("DATAVERSE_TENANT_ID") or os.environ.get("TENANT_ID")
        if dataverse_tenant_id:
            token_cmd.extend(["--tenant", dataverse_tenant_id])
        token_result = subprocess.run(token_cmd, capture_output=True, text=True, check=False)
        if token_result.returncode != 0:
            raise RuntimeError(
                "Failed to get Azure CLI access token. Run az login for the Dataverse tenant. "
                f"stderr: {token_result.stderr.strip()}"
            )
        token = token_result.stdout.strip()
        if not token:
            raise RuntimeError("Azure CLI returned an empty Dataverse access token")
    else:
        raise ValueError("DATAVERSE_TDS_TOKEN_SOURCE must be either sdk or az")

    query_timeout_arg = ""
    if timeout_seconds:
        query_timeout_arg = f" -QueryTimeout {int(timeout_seconds)}"

    command = (
        "$ErrorActionPreference = 'Stop'; "
        f"$token = {_ps_single_quoted(token)}; "
        "$rows = Invoke-Sqlcmd"
        f" -ServerInstance {_ps_single_quoted(host)}"
        " -AccessToken $token"
        f" -Query {_ps_single_quoted(sql)}"
        " -TrustServerCertificate"
        f"{query_timeout_arg}; "
        "$rows | ConvertTo-Csv -NoTypeInformation"
    )
    powershell_exe = shutil.which("pwsh.exe") or shutil.which("pwsh") or shutil.which("powershell.exe") or shutil.which("powershell")
    if not powershell_exe:
        raise RuntimeError("PowerShell executable was not found on PATH")

    try:
        result = subprocess.run(
            [powershell_exe, "-NoProfile", "-Command", command],
            capture_output=True,
            text=True,
            check=False,
            timeout=(timeout_seconds + 120) if timeout_seconds else None,
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(f"Invoke-Sqlcmd timed out after {exc.timeout} seconds") from exc
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    output = result.stdout.strip()
    if not output:
        return []
    return list(csv.DictReader(io.StringIO(output)))


def close_tds_connections() -> None:
    """Compatibility no-op for callers that used the previous pyodbc cache."""
    return None


def execute_sql_dataverse(
    db_id: str,
    sql: str,
    fetch: Union[str, int] = "all",
    timeout_seconds: Optional[int] = 30,
) -> Any:
    """Execute a Dataverse TDS SQL query and fetch rows.

    `fetch` matches the existing sqlite helper: "all", "one", or an integer.
    Returned rows are tuples, with columns ordered as emitted by Invoke-Sqlcmd.
    """
    rows = _invoke_sqlcmd(db_id, sql, timeout_seconds=timeout_seconds)
    tuple_rows = [tuple(row.values()) for row in rows]

    if fetch == "all":
        return tuple_rows
    if fetch == "one":
        return tuple_rows[0] if tuple_rows else None
    if isinstance(fetch, int):
        return tuple_rows[:fetch]
    raise ValueError("Invalid fetch argument. Must be 'all', 'one', or an integer.")


def execute_sql_dataverse_records(
    db_id: str,
    sql: str,
    timeout_seconds: Optional[int] = 30,
) -> list[dict[str, Any]]:
    """Execute Dataverse TDS SQL and return rows as dictionaries."""
    return _invoke_sqlcmd(db_id, sql, timeout_seconds=timeout_seconds)


def _normalize_value(value: Any) -> Any:
    if isinstance(value, Decimal):
        return round(float(value), 8)
    if isinstance(value, datetime):
        return value.isoformat(timespec="seconds")
    if isinstance(value, (date, time)):
        return value.isoformat()
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    return value


def _normalize_rows(rows: Any) -> set[tuple[Any, ...]]:
    if rows is None:
        return set()
    normalized = []
    for row in rows:
        if not isinstance(row, tuple):
            row = tuple(row)
        normalized.append(tuple(_normalize_value(value) for value in row))
    return set(normalized)


def compare_sqls_outcomes_dataverse(db_id: str, predicted_sql: str, ground_truth_sql: str) -> int:
    """Return 1 when predicted and gold Dataverse SQL produce the same row set."""
    predicted_res = execute_sql_dataverse(db_id, predicted_sql)
    ground_truth_res = execute_sql_dataverse(db_id, ground_truth_sql)
    return int(_normalize_rows(predicted_res) == _normalize_rows(ground_truth_res))


def compare_sqls_dataverse(
    db_id: str,
    predicted_sql: str,
    ground_truth_sql: str,
    meta_time_out: int = 30,
) -> Dict[str, Union[int, str]]:
    """Compare Dataverse SQL queries using the existing E-SQL result shape."""
    try:
        res = compare_sqls_outcomes_dataverse(db_id, predicted_sql, ground_truth_sql)
        error = "incorrect answer" if res == 0 else "--"
    except Exception as exc:
        logging.error("Error in compare_sqls_dataverse: %s", exc)
        res = 0
        error = str(exc)
    return {"exec_res": res, "exec_err": error}
