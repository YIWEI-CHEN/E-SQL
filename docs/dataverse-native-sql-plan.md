# Series 2 — Native Dataverse T-SQL Generation Plan

This branch tracks the work to extend the E-SQL framework so it natively
generates **Dataverse T-SQL** (executed against Dataverse environments via the
TDS endpoint) for the `soccer`, `california_schools`, and `student_club`
datasets. Series 1 (SQLite, BIRD-style execution) remains the default and is
not regressed by this work — every change is gated behind a new
`--exec_engine` flag and selects an engine-specific code path.

> Status: **planning only**. No production code changes have been made on this
> branch yet. Each section below maps to a future commit / PR.

---

## 0. Dataverse SQL one-pager (reference)

Authoritative dialect rules the model is told to follow. Embedded verbatim in
every generation/refinement system prompt for `exec_engine=dataverse`.

- Identifier quoting: `[name]` (square brackets) — never backticks, never
  double quotes for identifiers.
- Pagination: `SELECT TOP n` — no `LIMIT n`, no `OFFSET … FETCH` on the TDS
  endpoint.
- String concat: `+` or `CONCAT(...)` — not `||`.
- Booleans: bit columns (`0/1`); no `TRUE/FALSE` literals.
- Dates: `DATEPART`, `DATEADD`, `DATEDIFF`, `FORMAT` — never `strftime`,
  `date()`, `julianday()`.
- Null-safe: `ISNULL(a, b)` (not `IFNULL`); `COALESCE` allowed.
- Aggregation: `STRING_AGG` — not `GROUP_CONCAT`.
- Joins: explicit `JOIN ... ON`; no `USING(col)`, no `NATURAL JOIN`.
- Lookup columns appear as `_<rel>_value` (GUID). Human-readable text lives
  on the related entity and requires a join.
- Choice / OptionSet columns are integers. Resolve labels via a join to
  `StringMap` (or expose the labels in the rendered schema — see §3.2).
- Forbidden in TDS: DDL/DML, `PRAGMA`, `INFORMATION_SCHEMA.*` (except a tiny
  allow-list), temp tables, recursive CTEs, full-text predicates.
- Audit columns are suppressed from the rendered schema unless mentioned in
  the question: `createdon`, `createdby`, `modifiedon`, `modifiedby`,
  `statecode`, `statuscode`, `versionnumber`, `importsequencenumber`,
  `overriddencreatedon`, `timezoneruleversionnumber`,
  `utcconversiontimezonecode`.

---

## 1. Engine-aware abstraction

Introduce an `EngineConfig` dataclass that bundles everything dialect-specific.
The Pipeline + runners pick one based on `--exec_engine ∈ {sqlite, dataverse}`
and pass it through.

`EngineConfig` carries:
- `name`: `"sqlite"` | `"dataverse"`
- `system_prompts`: dict keyed by stage
  (`candidate_sql_generation`, `sql_refinement`, `schema_filtering`,
  `question_enrichment`)
- `prompt_template_paths`: per-stage template file
- `few_shot_pool_path`: per-engine few-shot file
- `schema_renderer`: `(db_id, schema_dict) -> str`
- `value_sampler`: `(question, evidence, schema_dict, sample_limit) -> str`
- `execute`: `(db_handle, sql) -> rows` (used by the refinement exec-err probe)
- `compare`: `(db_handle, predicted, gold) -> {exec_res, exec_err}`
- `sqlglot_dialect`: `"sqlite"` or `"tsql"` — used everywhere
  `parse_one(..., read=...)` / `qualify(..., read=...)` are called
- `post_fixups`: optional minimal lint pass (see §10)

---

## 2. Dataverse access layer — SDK + TDS

The Microsoft `Dataverse-skills` repo confirms that the Python SDK
(`PowerPlatform-Dataverse-Client`) is useful for authentication, metadata,
simple reads, DataFrame extraction, and Web API helpers. It **does not replace
TDS for E-SQL execution accuracy**, because `client.query.sql()` uses the
Dataverse Web API `?sql=` parameter and does not support key SQL constructs we
need for BIRD-style EX scoring: `JOIN`, `GROUP BY`, `HAVING`, `DISTINCT`,
subqueries, and large result sets beyond ~5,000 rows.

Therefore the access layer is split deliberately:

### 2.1 SDK helper — `utils/dataverse_sdk.py`

1. Reuse the auth pattern from `Dataverse-skills/scripts/auth.py`:
   service principal when `CLIENT_ID` + `CLIENT_SECRET` are present, otherwise
   device-code auth with a persistent token cache.
2. Return a `DataverseClient` via `PowerPlatform.Dataverse.client.DataverseClient`
   for SDK-based operations.
3. Use SDK paths for:
   - connectivity smoke tests (`client.records.get(...)` or simple
     `client.query.sql("SELECT TOP 1 ...")`)
   - metadata/schema discovery when the SDK supports it
   - simple table reads and DataFrame extraction
   - prompt sample extraction where full SQL semantics are not needed

### 2.2 TDS SQL executor — `utils/dataverse_utils.py`

1. AAD token via Azure CLI (`az account get-access-token --resource https://<org>`),
   matching the proven `dv-sql` skill path.
2. PowerShell `Invoke-Sqlcmd` against the Dataverse TDS endpoint
   (`<org>.crm.dynamics.com`). This avoids pyodbc token-auth edge cases while
   still exercising the same read-only TDS endpoint.
3. Per-`db_id` env routing via env vars:
   - `DATAVERSE_ENV_SOCCER`
   - `DATAVERSE_ENV_CALIFORNIA_SCHOOLS`
   - `DATAVERSE_ENV_STUDENT_CLUB`

   …with an optional `dataverse/env_map.json` override.
4. Connection pool keyed by `db_id` (one connection per env, lazy-init).
5. Public API mirroring `utils/db_utils.py`:
   - `execute_sql_dataverse(db_id, sql)`
   - `compare_sqls_outcomes_dataverse(db_id, predicted, gold)`
   - `compare_sqls_dataverse(db_id, predicted, gold, meta_time_out=30)`

   …returning the same `{exec_res, exec_err}` shape so downstream
   bookkeeping is unchanged.
6. Row normalization for stable set comparison:
   - `Decimal` → `float` with tolerance
   - strip trailing-zero datetime fractions
   - canonicalize tuple element ordering

---

## 3. Schema renderer — `utils/dataverse_schema.py`

### 3.1 Static structure from Dataverse metadata
Hit Dataverse Web API once per environment
(`/api/data/v9.2/EntityDefinitions(...)/Attributes`) to pull real logical
names, types, lookups, choice columns, and the primary key. Cache the result
to `dataverse/schema_cache/<db_id>.json`. Render T-SQL `CREATE TABLE` from
the cache:

```sql
CREATE TABLE [account] (
  [accountid] uniqueidentifier PRIMARY KEY,
  [name] nvarchar(160),
  [_primarycontactid_value] uniqueidentifier,
  ...
)
```

### 3.2 Lookup & choice annotations
Each lookup column emits an inline comment such as
`-- lookup → contact(contactid); join contact ON contact.contactid = account._primarycontactid_value`.
Each choice column emits `-- choice; labels: 1=Hot, 2=Warm, 3=Cold`
(pulled from OptionSet metadata at cache build time). This is the single
biggest signal the model needs to write correct Dataverse SQL first-try.

### 3.3 Audit-column suppression toggle
Skip audit columns unless the question mentions them. Saves ~30–50% of
prompt tokens.

---

## 4. Prompt templates

| Template | Action |
|---|---|
| `candidate_sql_generation_prompt_template.txt` | **Sibling** `_dataverse.txt`: swap "SQLite SQL" → "Dataverse T-SQL", swap backtick rule → square brackets, swap `LIMIT 1` → `TOP 1 ... ORDER BY`. Append §0 rules block. |
| `sql_refinement_prompt_template.txt` | **Sibling** `_dataverse.txt`: same edits, plus 3–5 example Dataverse server errors and their fixes so the model can interpret terse SQL-Server-style messages from the refinement exec probe. |
| `schema_filter_prompt_template.txt` | **Light edit** sibling — strip "SQLite" wording; otherwise dialect-agnostic. |
| `question_enrichment_prompt_template.txt` | **Light edit** sibling — strip "SQLite"; otherwise dialect-agnostic. |

Runner picks the `_dataverse.txt` sibling when `--exec_engine=dataverse`.

---

## 5. System messages — `utils/azure_openai_utils.py`

`create_response` currently hardcodes "valid SQLite SQL query" in the
`candidate_sql_generation` and `sql_refinement` system messages. Refactor so
system text comes from `EngineConfig.system_prompts[stage]` and is passed in
by the caller. Add two new strings declaring "valid Dataverse T-SQL". Keep
SQLite strings for series-1 compatibility.

---

## 6. Few-shot pools

### 6.1 SQL generation / refinement
Today `sql_generation_and_refinement_few_shot_prep` in `utils/prompt_utils.py`
sources live from BIRD gold (SQLite). Build a Dataverse-native pool:

1. Create `few-shot-data/sql_generation_dataverse.json` with **30–60 curated
   (question, schema, Dataverse-SQL) triples**, covering: top-N,
   group-by-having, lookup→entity join, choice→`StringMap` join, date range
   with `DATEPART`, null handling with `ISNULL`, string match with `LIKE` /
   `CHARINDEX`, set-diff via `EXCEPT`, multi-hop join through link entity,
   paging with `TOP`, decimal aggregation.
2. Bootstrap by transpiling existing BIRD few-shots via
   `sqlglot(read="sqlite", write="tsql")`, then **manually validate each one
   against Dataverse**. Expect ~40% throw-away.
3. Hand-author 10–15 exemplars unique to `soccer` / `california_schools` /
   `student_club` to cover the dialect-specific traps in their data.
4. Update `sql_generation_and_refinement_few_shot_prep` to load from
   `EngineConfig.few_shot_pool_path` and skip the
   `db_path = .../{db_id}.sqlite` schema rebuild when engine is Dataverse
   (use the cached schema from §3 instead).

### 6.2 Question enrichment
`few-shot-data/question_enrichment_few_shot_examples.json` (~99 KB, 404 lines)
is mostly natural language. **Leave as-is in v1.** Only sibling it if traces
show enrichment steering the model toward SQLite-specific phrasing.

### 6.3 Schema filtering
Reuses the SQL-generation pool. `schema_filtering_few_shot_prep` reads the
same `EngineConfig.few_shot_pool_path`.

---

## 7. `utils/prompt_utils.py` — engine awareness

- All three `*_few_shot_prep` functions take an `engine: EngineConfig`
  parameter (or read it from a contextvar set at Pipeline init).
- When engine is Dataverse: load from `engine.few_shot_pool_path` and render
  schemas via the cached Dataverse metadata, not from sqlite files.
- `sql_possible_conditions_prep` emits `[bracketed]` identifiers (not
  backticks) for Dataverse.
- `construct_sql_refinement_prompt` strings like
  `"### Possible SQLite SQL Query:"` and `"While generating new SQLite SQL
  query …"` become engine-conditional.

---

## 8. `utils/db_utils.py` — dialect switch

- Every `parse_one(sql, read='sqlite')` becomes
  `parse_one(sql, read=engine.sqlglot_dialect)`. Affected:
  `extract_sql_tables`, `extract_sql_tables_with_aliases`,
  `extract_sql_columns`, `replace_alias_with_table_names_in_sql`,
  `get_comparison_conditions_from_sql`, `collect_possible_conditions`.
- Same change for `qualify(..., read='sqlite')`.
- `clean_sql` replaces `"` with backticks today; emit `[ ... ]` (or no-op)
  for Dataverse.
- `generate_schema_from_schema_dict` stays sqlite-only; the Dataverse renderer
  in §3 lives in a sibling module and the engine config picks one.
- `extract_db_samples_enriched_bm25` and `find_similar_values_*`: when
  Dataverse is selected, route their `execute_sql` calls through
  `dataverse_utils.execute_sql_dataverse` so few-shot value hints reflect the
  *actual* Dataverse data shape (GUIDs for lookups, ints for choices). Cache
  aggressively per `(db_id, table, column)` — TDS round-trips are slow.

---

## 9. `pipeline/Pipeline.py` — engine plumbing

Three places hardcode `db_path = .../{db_id}.sqlite`
(`Pipeline.py:70, 171, 303`). Replace with:

```python
db_handle = engine.db_handle_for(db_id)  # sqlite path OR db_id, opaque
```

…and pass `db_handle` everywhere `db_path` flows. The three `execute_sql`
probe calls (`Pipeline.py:99, 198, 360`) become
`engine.execute(db_handle, possible_sql)`. **This is essential** — the
refinement loop only works as a teacher signal if the exec-error comes from
the same backend the LLM is targeting.

`Pipeline(args)` reads `args.exec_engine` and constructs the engine once.

---

## 10. Narrow post-generation safety net

LLMs occasionally slip back to SQLite habits. A tiny lint+autofix
(`utils/dataverse_postfix.py`, ~50 LOC) runs on model output before execute:

- Backticks → square brackets
- Simple `LIMIT n` → `SELECT TOP n` rewrite (skip if `OFFSET` present)
- `||` between string operands → `+`
- `strftime('%Y'|'%m'|'%d', …)` → `DATEPART(...)`

Anything more exotic is sent to Dataverse as-is so the refinement loop sees
the real error and learns.

---

## 11. Runners — `check_correctness` dispatch

Three files: `main.py`, `main_azure_dev_db.py`, `main_azure_soccer.py`.

- Add `--exec_engine ∈ {sqlite, dataverse}` (default `sqlite`).
- Build `EngineConfig` once.
- `check_correctness` dispatches to `engine.compare(...)`.
- Output dir tagged `_dv` when engine is Dataverse so series-1 and series-2
  result folders don't collide.

---

## 12. Gold SQL for Dataverse

Series 2 needs a Dataverse-SQL **gold** to score against. Cache it at
`dataverse/gold_translated/<db_id>.json` (shape:
`{question_id: {sqlite, dataverse, exec_ok, exec_err}}`). Produced once by
`scripts/translate_gold_for_dataverse.py` (sqlglot transpile → execute →
hand-fix failures). This is **independent of the generation strategy** — it
characterizes the evaluation target, not the model.

`check_correctness` reads the cached `dataverse` field instead of
translating per-call.

---

## 13. Offline evaluator (optional)

If you want `evaluation/evaluation_ex.py` to also work against Dataverse:
add a `"Dataverse"` branch in `evaluation/evaluation_utils.py::connect_db`,
parse `db_id` from the saved `predict_<mode>.json` separator
(`<sql>\t----- bird -----\t<db_id>`), reuse `dataverse_utils`. Skip if the
in-process EX in `metrics.json` is sufficient.

---

## 14. Files touched — inventory

**New**

- `utils/engine_config.py` — `EngineConfig` dataclass + factory
- `utils/dataverse_sdk.py` — SDK auth helper, `DataverseClient` factory,
  simple read/smoke utilities
- `utils/dataverse_utils.py` — connector, execute, compare
- `utils/dataverse_schema.py` — Web API metadata pull + T-SQL CREATE TABLE
  renderer + cache loader
- `utils/dataverse_postfix.py` — lint+autofix safety net (§10)
- `prompt_templates/candidate_sql_generation_prompt_template_dataverse.txt`
- `prompt_templates/sql_refinement_prompt_template_dataverse.txt`
- `prompt_templates/schema_filter_prompt_template_dataverse.txt`
  (light variant)
- `few-shot-data/sql_generation_dataverse.json` — **main authoring cost**
- `scripts/translate_gold_for_dataverse.py`
- `scripts/pull_dataverse_schema.py`
- `dataverse/env_map.json` (optional; env vars are the alternative)
- `dataverse/schema_cache/{soccer,california_schools,student_club}.json`
- `dataverse/gold_translated/{soccer,california_schools,student_club}.json`
- `dataverse/dataverse_sql_guide.md` (the §0 one-pager — embedded in prompts)

**Edited**

- `utils/azure_openai_utils.py` — parameterized system messages, Dataverse
  variants
- `utils/prompt_utils.py` — engine-aware few-shot prep,
  `sql_possible_conditions_prep`, `construct_sql_refinement_prompt`
- `utils/db_utils.py` — engine-aware sqlglot dialect; `clean_sql` quoting
- `pipeline/Pipeline.py` — accept `engine`; replace all `db_path` plumbing
- `main.py`, `main_azure_dev_db.py`, `main_azure_soccer.py` — add
  `--exec_engine`, build `EngineConfig`, route `check_correctness`
- `requirements.txt` — pinned `azure-identity`, `PowerPlatform-Dataverse-Client`,
  `pandas`, optional `requests` for metadata pulls / Web API fallbacks
- `env.example`, `README.md`

**Deferred unless needed**

- `few-shot-data/question_enrichment_few_shot_examples.json`
- `evaluation/evaluation_ex.py`

---

## 15. Phased rollout

Five PRs so we can stop or pivot at any boundary:

| Phase | Deliverable | Validates |
|---|---|---|
| P1 | Dataverse access proof: SDK auth/simple-read smoke + TDS `SELECT TOP 1 …` smoke per db | SDK setup works; TDS auth works; all 3 envs reachable |
| P2 | `pull_dataverse_schema.py`, schema cache, `dataverse_schema.py` renderer | Schema strings correct & token-economical |
| P3 | `translate_gold_for_dataverse.py` produces gold caches; hand-patch failures | Establishes the **EX ceiling** |
| P4 | `EngineConfig`, new prompts, system messages, bootstrapped few-shot pool, `Pipeline.py` plumbing | End-to-end on 10 questions / db; compare against series-1 |
| P5 | Curated/hand-authored few-shots (§6.1 step 3), post-fixups, full run, metrics, write-up | Final series-2 EX numbers |

Hard validation gates:

- After P1:
  - SDK smoke succeeds for all 3 dbs using `PowerPlatform-Dataverse-Client`
    (`client.records.get(...)` or a limited `client.query.sql("SELECT TOP 1 ...")`).
  - TDS smoke succeeds for all 3 dbs, e.g.
    `python -c "from utils.dataverse_utils import execute_sql_dataverse; print(execute_sql_dataverse('soccer','SELECT TOP 1 [name] FROM [team]'))"`.
  - Document explicitly that SDK SQL is **not** the EX execution backend; TDS
    remains required for joins, grouping, distinct, subqueries, and full result
    comparison.
- After P3: report `gold_ok_count / total` per db. If <90%, fix the
  translator before authoring new prompts/few-shots.
- After P4: take 10 questions where series-1 scored EX=1, verify the new
  prompts also produce Dataverse SQL scoring 1. If <70%, iterate on
  few-shots/system prompt before the full run.

---

## 16. Risks

- **Few-shot authoring is the long pole.** Budget 1–2 person-days for a
  competent curated pool. Bootstrapping gets you ~60%; the rest is hand work.
- **`exec_err` quality is critical.** Dataverse TDS errors are terse and
  often misleading (e.g., "Invalid object name" for forbidden functions).
  The refinement template must give explicit interpretation examples.
- **Lookup/choice semantics hurt EX** even when SQL is correct: gold returns
  labels while predicted returns GUIDs/ints (or vice versa). The schema
  annotations in §3.2 mitigate, the row normalization in §2.6 catches the
  rest.
- **TDS throttling** matters more here than in the rewriter alternative
  because the refinement exec probe also hits Dataverse. Per-call timeout +
  short-circuit (skip the probe under rate-limit) is mandatory.
- **Series-1 ↔ series-2 comparability**: with both prompts and execution
  changing, an EX delta is not cleanly attributable to "Dataverse is harder"
  vs "prompts got worse". If that attribution matters, run a third config —
  SQLite prompts + rewriter + Dataverse exec — as the bridge.

---

## Out of scope on this branch

- `pipeline/Pipeline.py` SQLite probe call (`execute_sql(db_path, possible_sql)`)
  for series-1 — unchanged.
- Schema/sample mining for series-1 (`utils/db_utils.py` sqlite paths) —
  unchanged.
- BIRD-format gold files — unchanged.
