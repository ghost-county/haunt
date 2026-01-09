# Naming Conventions for Upland EDP

This document consolidates naming conventions across all Upland data engineering technologies based on the most commonly used patterns.

## Table of Contents
- [General Principles](#general-principles)
- [dbt Naming](#dbt-naming)
- [Snowflake Naming](#snowflake-naming)
- [Airflow Naming](#airflow-naming)
- [Column Naming](#column-naming)

---

## General Principles

1. **Be descriptive** - Names should indicate purpose
2. **Be consistent** - Follow patterns within each technology
3. **Use underscores** - snake_case for multi-word names
4. **Indicate layer** - Make architectural layer obvious
5. **Include source** - Reference source system where relevant

---

## dbt Naming

### Model Files

| Layer | Type | Pattern | Example |
|-------|------|---------|---------|
| Silver | Staging | `stg_[source]_[entity]` | `stg_telenet_claim_change_event` |
| Silver | Hub | `[entity]_hub` | `claim_hub`, `policy_hub` |
| Silver | Satellite | `[entity]_[attribute]_hub` | `claim_payment_hub`, `loss_reserve_hub` |
| Gold | Staging | `stg_[domain]_[entity]` | `stg_marketstance_sales_size` |
| Gold | Power BI | `pbi_[dashboard]` | `pbi_submission_inbox_current` |
| Gold | Mart | `[domain]_[purpose]` | `premium_production_dashboard` |

### Schema Names

| Purpose | Schema Name | Example |
|---------|-------------|---------|
| Staging | `stage` | Silver staging models |
| Data Vault | `vault` | Hub and satellite tables |
| Reference | `reference` | Lookup/dimension data |
| Domain-specific | `[domain_name]` | `claim_reporting`, `finance_reporting` |

**Environment handling via generate_schema_name macro:**
- DEV: `[developer]_[schema]` (e.g., `MICHAEL_vault`)
- PROD/TEST: `[schema]` (e.g., `vault`)

### Database Names

| Environment | Bronze | Silver | Gold |
|-------------|--------|--------|------|
| DEV | `DEV_UPLAND_BRONZE_DB` | `DEV_UPLAND_SILVER_DB` | `DEV_UPLAND_GOLD_DB` |
| TEST | `TEST_UPLAND_BRONZE_DB` | `TEST_UPLAND_SILVER_DB` | `TEST_UPLAND_GOLD_DB` |
| PROD | `PROD_UPLAND_BRONZE_DB` | `PROD_UPLAND_SILVER_DB` | `PROD_UPLAND_GOLD_DB` |

**Utility databases** (no environment prefix):
- `UPLAND_UTIL`
- `UPLAND_MAINTENANCE`

### Snapshot Names

Pattern: `[SOURCE]_[TABLE]`

**Configuration:**
- File location: `snapshots/[source]_snapshots.yml`
- Snapshot name: Matches source table (e.g., `CLAIM`)
- Alias: Removes `STG_` prefix if present

**Example:**
```yaml
snapshots:
  - name: FS_PRD_CLAIM
    relation: source('fivesigma', 'stg_claim')
    config:
      alias: CLAIM  # Output table name
```

---

## Snowflake Naming

### Tables

| Layer/Type | Pattern | Example |
|------------|---------|---------|
| Bronze staging | `STG_[entity]` | `STG_CLAIM`, `STG_PAYMENT` |
| Bronze snapshot | `[entity]` | `CLAIM`, `PAYMENT` |
| Silver hub | `[entity]_HUB` | `CLAIM_HUB` |
| Silver satellite | `[entity]_[attribute]_HUB` | `CLAIM_PAYMENT_HUB` |
| Gold marts | `[domain]_[purpose]` | `PREMIUM_PRODUCTION_DASHBOARD` |
| Gold Power BI | `PBI_[dashboard]` | `PBI_UW360` |
| Utility tables | `[PURPOSE]_[TYPE]` | `CSV_TABLE_SUM_VALIDATION_LOG` |
| Audit tables | `[ENTITY]_LOG` | `FILE_INGESTION_LOG` |

**Case conventions:**
- Bronze/Silver raw tables: UPPERCASE
- dbt-managed tables: As defined in model (usually lowercase)

### Views

Pattern: `[name]_VW`

**Examples:**
- `NETWORK_ADJUSTERS_CSV_IMPORT_STAGE_FILES_VW`
- `CLAIM_DETAIL_CURRENT_VW`

### Stored Procedures

Pattern: `[NAME]_SP` or descriptive name

**Examples:**
- `CSV_IMPORT_V2_SP`
- `FIVESIGMA_CSV_IMPORT`
- `SP_GRANT_READ_PERMS`
- `SP_GRANT_READWRITE_PERMS`
- `GET_CSV_VALIDATION_SUMMARY_SP`

### File Formats

Pattern: `[source]_[type]_FORMAT`

**Examples:**
- `NA_CSV_FORMAT`
- `NA_CSV_FORMAT_SCHEMA`
- `FS_CSV_FORMAT`

### External Stages

Pattern: `[source]_[type]_[env]_STG`

**Examples:**
- `FIVESIGMA_CSV_PROD_STG`
- `NETWORK_ADJUSTERS_CSV_PROD_STG`
- `NETWORK_ADJUSTERS_CSV_DEV_STG`

### Storage Integrations

Pattern: `[source]_[type]_INT`

**Examples:**
- `NETWORK_ADJUSTERS_CSV_INT`
- `FIVESIGMA_AZURE_INT`

### Schemas in UPLAND_UTIL

| Purpose | Schema Name | Usage |
|---------|-------------|-------|
| Common utilities | `COMMON` | Shared procedures like CSV_IMPORT_V2_SP |
| Security | `SECURITY` | Permission management procedures |
| Audit | `AUDIT` | Audit logging tables |
| Source-specific | `[SOURCE_NAME]` | FIVESIGMA, NETWORK_ADJUSTERS, etc. |

---

## Airflow Naming

### DAG Files

Pattern: `[Source]_[Operation]_[Environment].py`

**Examples:**
- `FiveSigma_CSV_Ingestion_Pipeline_Prod.py`
- `FiveSigma_CSV_Ingestion_Pipeline_Dev.py`
- `NetAdj_CSV_Batch_Ingestion_Prod.py`

**Case convention:** PascalCase for readability

### DAG Function Names

Pattern: Matches file name

**Example:**
```python
# File: FiveSigma_CSV_Ingestion_Pipeline_Dev.py
@dag(...)
def FiveSigma_CSV_Ingestion_Pipeline_Dev():
    pass
```

### Task IDs

Pattern: `snake_case` descriptive names

**Examples:**
- `extract_zip_files`
- `test_snowflake_connection`
- `csv_ingestion_stored_proc`
- `validate_csv_sums`
- `archive_zip_files`
- `cleanup_csv_files`

### DAG Tags

Pattern: `["source", "operation-type", "frequency"]`

**Examples:**
```python
tags=["fivesigma", "csv-ingestion", "daily"]
tags=["network-adjusters", "csv-batch", "daily"]
tags=["azure", "security-update", "weekly"]
```

### Connection IDs

Pattern: `[SYSTEM]_[PURPOSE]` or `[system]_[purpose]`

**Examples:**
- `UCG_SVC_ASTRONOMER_KP` (Snowflake with key pair)
- `dbt_Conn` (dbt Cloud)
- `apprise_default` (Notifications)
- `UCG_FIVETRAN_CONN` (Fivetran)

### Python Function Names

Pattern: `snake_case`

**Examples:**
```python
def extract_daily_zip(**context):
def archive_zip_files(**context):
def validate_csv_table_sums(**context):
def notify_failure(context: Context):
```

---

## Column Naming

### General Conventions

- Use **snake_case** for all column names
- Be descriptive and clear
- Avoid abbreviations unless standard (e.g., `id`, `uid`)
- Include data type hints in suffix where helpful

### Standard Suffixes

| Data Type | Suffix | Example |
|-----------|--------|---------|
| Surrogate key | `_uid` | `claim_uid`, `policy_uid` |
| Natural key | `_id` or `_number` | `claim_id`, `policy_number` |
| Boolean | `_flag` or `_indicator` | `is_active_flag`, `closed_indicator` |
| Timestamp | `_timestamp` | `created_timestamp`, `modified_timestamp` |
| Date only | `_date` | `effective_date`, `expiration_date` |
| Amount/Money | `_amount` | `payment_amount`, `premium_amount` |
| Count | `_count` | `claim_count`, `payment_count` |

### Data Vault Required Columns

All Data Vault tables must include:

| Column | Data Type | Purpose |
|--------|-----------|---------|
| `valid_from` | TIMESTAMP_NTZ | Record validity start |
| `valid_to` | TIMESTAMP_NTZ | Record validity end (NULL for current) |
| `change_event` | VARCHAR | INSERT, UPDATE, or DELETE |
| `record_source` | VARCHAR | Source system identifier |

### dbt Snapshot Columns

Automatically added by dbt:

| Column | Purpose |
|--------|---------|
| `dbt_scd_id` | Unique ID for each snapshot row |
| `dbt_updated_at` | When dbt last updated this row |
| `dbt_valid_from` | When this version became valid |
| `dbt_valid_to` | When this version became invalid |

### Audit Table Columns

Standard columns for audit/log tables:

| Column | Data Type | Purpose |
|--------|-----------|---------|
| `log_id` or `[table]_id` | NUMBER(38,0) AUTOINCREMENT | Primary key |
| `job_name` | VARCHAR | Name of job/DAG |
| `runtime` | TIMESTAMP_NTZ | When event occurred |
| `status` | VARCHAR | SUCCESS, FAILED, ERROR, etc. |
| `error_message` | VARCHAR(5000) | Error details if failed |

---

## Special Cases and Exceptions

### Power BI Models

Use `pbi_` prefix:
- `pbi_submission_inbox_current`
- `pbi_uw360`
- `pbi_claim_dashboard`

### Reference Data

Use `ref_` prefix if not in reference schema:
- `ref_state_codes`
- `ref_loss_categories`

Or place in `reference` schema without prefix:
- `state_codes` (in reference schema)

### Temporary Tables

Use `tmp_` prefix:
```sql
CREATE TEMPORARY TABLE tmp_staging_data AS ...
```

### Incremental Models

No special prefix needed, but document materialization in config:
```sql
{{
  config(
    materialized='incremental',
    unique_key='transaction_id'
  )
}}
```

---

## Quick Reference Table

| Object Type | Pattern | Example |
|-------------|---------|---------|
| **dbt silver staging** | `stg_[source]_[entity]` | `stg_telenet_claim` |
| **dbt hub** | `[entity]_hub` | `claim_hub` |
| **dbt satellite** | `[entity]_[attr]_hub` | `claim_payment_hub` |
| **dbt gold PBI** | `pbi_[dashboard]` | `pbi_uw360` |
| **Snowflake staging** | `STG_[ENTITY]` | `STG_CLAIM` |
| **Snowflake view** | `[name]_VW` | `CLAIM_DETAIL_VW` |
| **Stored procedure** | `[NAME]_SP` | `CSV_IMPORT_V2_SP` |
| **External stage** | `[source]_[env]_STG` | `FIVESIGMA_PROD_STG` |
| **Airflow DAG file** | `[Source]_[Op]_[Env].py` | `FiveSigma_CSV_Ingestion_Pipeline_Prod.py` |
| **Airflow task** | `snake_case` | `extract_zip_files` |
| **Column surrogate key** | `[entity]_uid` | `claim_uid` |
| **Column boolean** | `[name]_flag` | `is_active_flag` |
| **Column timestamp** | `[event]_timestamp` | `created_timestamp` |

---

## Validation Checklist

When creating new objects, verify:

- [ ] Name follows appropriate pattern for object type
- [ ] Name indicates architectural layer (if applicable)
- [ ] Name indicates source system (if applicable)
- [ ] Case convention matches technology standards
- [ ] Name is descriptive and clear
- [ ] Name doesn't conflict with reserved keywords
- [ ] Name is documented/commented

---

## Conflict Resolution

When naming conventions conflict or are unclear:

1. **Check existing similar objects** in the same layer/technology
2. **Follow the most commonly used pattern** in the codebase
3. **Prioritize clarity over brevity**
4. **Document any deviation** with a comment explaining why

**In general:**
- dbt follows dbt community conventions
- Snowflake follows Upland internal conventions
- Airflow follows Astronomer/Airflow best practices
- When in doubt, ask the team or check existing code
