"""LLM helpers for Dataverse-native SQL experiments."""

from __future__ import annotations

import os
from typing import Any

from dotenv import load_dotenv


DATAVERSE_SYSTEM_MESSAGES = {
    "candidate_sql_generation": (
        "You are an excellent data scientist. Generate valid Dataverse T-SQL "
        "for the Microsoft Dataverse TDS endpoint. Use only read-only SELECT "
        "queries. Use square brackets for identifiers, SELECT TOP for top-N, "
        "DATEPART/DATEADD/DATEDIFF for date logic, + or CONCAT for string "
        "concatenation, and explicit JOIN ... ON clauses."
    ),
    "sql_refinement": (
        "You are an excellent data scientist. Refine a Dataverse T-SQL query "
        "for the Microsoft Dataverse TDS endpoint. Use the execution error, "
        "schema, question, and possible query to produce a corrected read-only "
        "SELECT query. Do not use SQLite syntax such as LIMIT, backticks, "
        "SUBSTR, GROUP_CONCAT, or strftime."
    ),
}


def create_dataverse_response(
    stage: str,
    prompt: str,
    model: str,
    max_tokens: int,
    temperature: float,
    top_p: float,
    n: int,
) -> Any:
    """Create a JSON-mode chat completion for Dataverse-native SQL stages."""
    load_dotenv()
    if stage not in DATAVERSE_SYSTEM_MESSAGES:
        raise ValueError(f"Unsupported Dataverse stage: {stage}")

    system_content = DATAVERSE_SYSTEM_MESSAGES[stage]
    endpoint = os.environ.get("AZURE_OPENAI_ENDPOINT")
    if not endpoint:
        raise ValueError("AZURE_OPENAI_ENDPOINT is required for Dataverse P4 Azure OpenAI runs")
    api_version = os.environ.get("AZURE_OPENAI_API_VERSION", "2024-10-21")
    tenant_id = os.environ.get("AZURE_TENANT_ID")

    from azure.identity import AzureCliCredential, ChainedTokenCredential, InteractiveBrowserCredential, get_bearer_token_provider
    from openai import AzureOpenAI

    credentials = []
    if tenant_id:
        credentials.extend([
            AzureCliCredential(tenant_id=tenant_id),
            InteractiveBrowserCredential(tenant_id=tenant_id),
        ])
    else:
        credentials.extend([AzureCliCredential(), InteractiveBrowserCredential()])

    token_provider = get_bearer_token_provider(
        ChainedTokenCredential(*credentials),
        "https://cognitiveservices.azure.com/.default",
    )
    client = AzureOpenAI(
        azure_endpoint=endpoint,
        azure_ad_token_provider=token_provider,
        api_version=api_version,
    )

    return client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_content},
            {"role": "user", "content": prompt},
        ],
        max_tokens=max_tokens,
        response_format={"type": "json_object"},
        temperature=temperature,
        top_p=top_p,
        n=n,
        presence_penalty=0.0,
        frequency_penalty=0.0,
    )
