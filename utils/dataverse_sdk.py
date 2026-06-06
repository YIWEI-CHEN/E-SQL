"""Dataverse SDK helpers for P1 connectivity and lightweight reads.

The SDK path is intentionally used for auth, metadata/simple reads, and smoke
checks. Full execution-accuracy SQL still goes through the Dataverse TDS
endpoint in utils.dataverse_utils because SDK SQL is a limited Web API subset.
"""

from __future__ import annotations

import json
import os
import re
from functools import lru_cache
from pathlib import Path
from typing import Iterable, Optional
from urllib.parse import urlparse

from dotenv import load_dotenv


DEFAULT_DB_IDS = ("soccer", "california_schools", "student_club")
ENV_MAP_PATH = Path("dataverse") / "env_map.json"


def normalize_db_id(db_id: str) -> str:
    """Normalize a db_id for env-var suffixes."""
    return re.sub(r"[^A-Za-z0-9]+", "_", db_id).strip("_").upper()


def dataverse_env_var_candidates(db_id: str) -> list[str]:
    """Return env var names that may contain the Dataverse URL for db_id."""
    normalized = normalize_db_id(db_id)
    candidates = [
        f"DATAVERSE_ENV_{normalized}",
        f"DATAVERSE_URL_{normalized}",
    ]

    # The BIRD train db is soccer_2016, but the experiment shorthand is soccer.
    if normalized == "SOCCER_2016":
        candidates.extend(["DATAVERSE_ENV_SOCCER", "DATAVERSE_URL_SOCCER"])
    elif normalized == "SOCCER":
        candidates.extend(["DATAVERSE_ENV_SOCCER_2016", "DATAVERSE_URL_SOCCER_2016"])

    # Preserve order while removing duplicates.
    return list(dict.fromkeys(candidates))


def _load_env_map() -> dict[str, str]:
    if not ENV_MAP_PATH.exists():
        return {}
    with ENV_MAP_PATH.open(encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        raise ValueError(f"{ENV_MAP_PATH} must contain a JSON object")
    return {str(k): str(v) for k, v in data.items()}


def get_dataverse_url(db_id: str) -> str:
    """Resolve db_id to a Dataverse environment URL."""
    load_dotenv()

    env_map = _load_env_map()
    if db_id in env_map:
        return env_map[db_id].rstrip("/")

    normalized = normalize_db_id(db_id)
    for key, value in env_map.items():
        if normalize_db_id(key) == normalized:
            return value.rstrip("/")

    for env_var in dataverse_env_var_candidates(db_id):
        value = os.environ.get(env_var)
        if value:
            return value.rstrip("/")

    expected = ", ".join(dataverse_env_var_candidates(db_id))
    raise ValueError(
        f"No Dataverse URL configured for db_id={db_id!r}. "
        f"Set one of: {expected}, or add it to {ENV_MAP_PATH}."
    )


def get_dataverse_host(db_id: str) -> str:
    """Resolve db_id to the Dataverse host name without scheme."""
    url = get_dataverse_url(db_id)
    parsed = urlparse(url if "://" in url else f"https://{url}")
    if not parsed.hostname:
        raise ValueError(f"Invalid Dataverse URL for db_id={db_id!r}: {url!r}")
    return parsed.hostname


def _get_tenant_id() -> Optional[str]:
    load_dotenv()
    return os.environ.get("DATAVERSE_TENANT_ID") or os.environ.get("TENANT_ID")


@lru_cache(maxsize=1)
def get_credential():
    """Return an Azure Identity credential suitable for Dataverse APIs."""
    load_dotenv()
    tenant_id = _get_tenant_id()
    client_id = os.environ.get("DATAVERSE_CLIENT_ID") or os.environ.get("CLIENT_ID")
    client_secret = os.environ.get("DATAVERSE_CLIENT_SECRET") or os.environ.get("CLIENT_SECRET")
    auth_mode = os.environ.get("DATAVERSE_AUTH_MODE", "auto").lower()

    try:
        from azure.identity import (
            AzureCliCredential,
            ChainedTokenCredential,
            ClientSecretCredential,
            DeviceCodeCredential,
            InteractiveBrowserCredential,
            TokenCachePersistenceOptions,
        )
    except ImportError as exc:
        raise ImportError(
            "azure-identity is required for Dataverse auth. "
            "Install with: pip install azure-identity"
        ) from exc

    if client_id and client_secret:
        if not tenant_id:
            raise ValueError("DATAVERSE_TENANT_ID or TENANT_ID is required for service principal auth")
        return ClientSecretCredential(
            tenant_id=tenant_id,
            client_id=client_id,
            client_secret=client_secret,
        )

    if auth_mode not in {"auto", "azure_cli", "device_code", "browser"}:
        raise ValueError("DATAVERSE_AUTH_MODE must be one of: auto, azure_cli, device_code, browser")

    def _device_code_credential():
        kwargs = {
            "client_id": "51f81489-12ee-4a9e-aaae-a2591f45987d",
            "cache_persistence_options": TokenCachePersistenceOptions(
                name="esql_dataverse",
                allow_unencrypted_storage=True,
            ),
        }
        if tenant_id:
            kwargs["tenant_id"] = tenant_id
        return DeviceCodeCredential(**kwargs)

    def _azure_cli_credential():
        if tenant_id:
            return AzureCliCredential(tenant_id=tenant_id)
        return AzureCliCredential()

    def _browser_credential():
        kwargs = {"client_id": "51f81489-12ee-4a9e-aaae-a2591f45987d"}
        if tenant_id:
            kwargs["tenant_id"] = tenant_id
        return InteractiveBrowserCredential(**kwargs)

    if auth_mode == "device_code":
        return _device_code_credential()
    if auth_mode == "browser":
        return _browser_credential()
    if auth_mode == "azure_cli":
        return _azure_cli_credential()

    # Auto mode prefers Azure CLI, but a wrong active CLI tenant can fail hard.
    # Set DATAVERSE_AUTH_MODE=device_code to bypass Azure CLI in that case.
    return ChainedTokenCredential(
        _azure_cli_credential(),
        _device_code_credential(),
    )


def get_access_token(db_id: str, scope: Optional[str] = None) -> str:
    """Acquire a bearer token for the target Dataverse environment."""
    if scope is None:
        scope = f"{get_dataverse_url(db_id)}/.default"
    return get_credential().get_token(scope).token


def get_client(db_id: str, **kwargs):
    """Return a PowerPlatform DataverseClient for db_id."""
    try:
        from PowerPlatform.Dataverse.client import DataverseClient
    except ImportError as exc:
        raise ImportError(
            "PowerPlatform-Dataverse-Client is required for SDK reads. "
            "Install with: pip install PowerPlatform-Dataverse-Client"
        ) from exc

    return DataverseClient(
        base_url=get_dataverse_url(db_id),
        credential=get_credential(),
        **kwargs,
    )


def iter_first_page(records_iterable: Iterable) -> list:
    """Return the first page from an SDK page iterator as a list."""
    for page in records_iterable:
        return list(page)
    return []


def sdk_read_smoke(db_id: str, table: str) -> int:
    """Read TOP 1 equivalent via the SDK and return the number of rows seen."""
    client = get_client(db_id)
    records = client.records.get(table, top=1)
    return len(iter_first_page(records))


def sdk_sql_smoke(db_id: str, sql: str) -> int:
    """Run a limited SDK SQL query and return the number of rows returned."""
    client = get_client(db_id)
    results = client.query.sql(sql)
    return len(list(results))
