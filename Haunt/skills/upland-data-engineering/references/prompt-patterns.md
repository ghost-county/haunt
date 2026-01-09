# Effective Prompting Patterns for Upland Data Engineering

This reference provides proven prompt templates and patterns for effective data engineering work at Upland Capital Group using the EDP stack (dbt Cloud, Snowflake, Astronomer/Airflow, Fivetran, Azure).

## Core Prompting Principles

1. **Be specific about layer and architecture** - "Build a silver layer hub table" > "Make a table"
2. **Explain business context first** - Help AI understand the data domain and business need
3. **Include technical constraints** - Database, schema, naming conventions, dependencies
4. **Request validation** - Ask AI to confirm approach aligns with Upland standards
5. **Reference existing patterns** - Point to similar models, DAGs, or procedures
6. **Build incrementally** - Start with bronze → silver → gold, not all at once

## Prompt Structure Template

```
[CONTEXT]
I'm working on [data domain] in the [layer] layer using [technology].

[BUSINESS INTENT]
The business needs to [business objective] because [why this matters].

[TECHNICAL REQUEST]
Create [specific artifact] that [technical requirements].

[UPLAND STANDARDS]
- Follow [specific naming convention]
- Use [specific macros/patterns]
- Integrate with [existing models/tables]

[VALIDATION REQUEST]
Please confirm this approach follows Upland EDP standards before generating code.
```

## Category-Specific Prompt Patterns

### 1. dbt Model Creation

**Pattern: Building a Silver Layer Hub Table**
```
Context: I'm building a new silver layer hub table for the [domain] business domain in dbt Cloud.

Business Intent: We need to track [entities] as unique business keys for Data Vault 2.0 integration across multiple source systems.

Technical Request:
Create a hub table for [entity_name] that:
- Sources from [bronze layer tables]
- Implements SCD Type 2 tracking with valid_from/valid_to
- Uses the vault_valid_to macro for temporal logic
- Includes change_event and record_source columns

Upland Standards:
- Naming: [entity]_hub (e.g., claim_hub, policy_hub)
- Schema: {{ config(schema='vault') }}
- Database: {{ env_var("DBT_SILVER_DB","DEV_UPLAND_SILVER_DB") }}
- Use convert_utc_to_central_tz macro for timestamps

Please confirm this approach follows Data Vault 2.0 and Upland patterns before generating.
```

**Example: Creating a Claim Payment Hub**
```
Context: I'm building a silver layer hub table for claim payments in dbt Cloud.

Business Intent: We need to track payment transactions as unique business keys to integrate payment data from FiveSigma and Network Adjusters systems.

Technical Request:
Create claim_payment_hub that:
- Sources from bronze.fivesigma.PAYMENTTRANSACTION
- Sources from bronze.network_adjusters_2.STG_PAYMENT
- Unions both sources with dbt_utils.union_relations
- Implements SCD Type 2 with valid_from/valid_to
- Uses vault_valid_to macro for calculating valid_to
- Tracks change_event (INSERT, UPDATE, DELETE)
- Includes record_source to identify origin system

Upland Standards:
- Table name: claim_payment_hub
- Schema: {{ config(schema='vault') }}
- Database: {{ env_var("DBT_SILVER_DB","DEV_UPLAND_SILVER_DB") }}
- Use convert_utc_to_central_tz for all timestamp columns
- Primary key: payment_uid (derived from source system ID)

Please confirm this follows Upland Data Vault patterns.
```

### 2. dbt Snapshot Creation

**Pattern: Creating Bronze Layer Snapshots**
```
Context: I need to create a dbt snapshot for [source table] in the bronze layer to track historical changes.

Business Intent: We need to preserve historical state of [data] to support [reporting/analysis need].

Technical Request:
Create a snapshot configuration that:
- Targets source table [database.schema.table]
- Uses check strategy with check_cols: all
- Implements hard_deletes: invalidate
- Sets dbt_valid_to_current: "to_date('2099-12-31')"
- Uses [columns] as unique_key

Upland Standards:
- Alias: [TABLE_NAME] (without STG_ prefix)
- Database: PROD_UPLAND_BRONZE_DB (or DEV for dev)
- Schema: [source_schema]
- Snapshot file location: snapshots/[source]_snapshots.yml

Please confirm this follows Upland snapshot patterns.
```

**Example: FiveSigma Claim Snapshot**
```
Context: I need to create a dbt snapshot for the FiveSigma claim staging table.

Business Intent: We need historical tracking of claim records to support change analysis and regulatory compliance.

Technical Request:
Create snapshot for FIVESIGMA.STG_CLAIM that:
- Checks all columns for changes
- Invalidates deleted records (sets valid_to)
- Uses ID as unique_key
- Outputs to FIVESIGMA.CLAIM (bronze layer)

Upland Standards:
- Snapshot file: snapshots/fivesigma_stg_snapshots.yml
- Alias: CLAIM (removes STG_ prefix)
- Database: PROD_UPLAND_BRONZE_DB
- Schema: FIVESIGMA
- Strategy: check with check_cols: all
- hard_deletes: invalidate
- dbt_valid_to_current: "to_date('2099-12-31')"

Configuration should match our existing 54 FiveSigma snapshots pattern.
```

### 3. Snowflake External Stage Creation

**Pattern: Creating Azure Blob Storage Stage**
```
Context: I need to create a Snowflake external stage to read CSV files from Azure Blob Storage for [data source].

Business Intent: We need to ingest [data type] files from [source system] delivered daily to Azure.

Technical Request:
Create external stage that:
- Connects to Azure storage account [account_name]
- Uses storage integration [integration_name]
- Points to container [container_name] and path [path]
- Includes file format for [CSV/Parquet/etc]

Upland Standards:
- Database: UPLAND_UTIL
- Schema: [SOURCE_NAME]
- Stage naming: [source]_[env]_STG (e.g., FIVESIGMA_CSV_PROD_STG)
- Integration naming: [source]_INT
- Include file discovery view
- Create grants for UPLAND_INGEST role

Please provide:
1. Storage integration DDL
2. External stage DDL
3. File format DDL (if needed)
4. File discovery view
5. Grant statements
```

**Example: Network Adjusters CSV Stage**
```
Context: I need to create an external stage for Network Adjusters CSV files in Azure Blob Storage.

Business Intent: We need to ingest daily claim adjuster data delivered as pipe-delimited text files to Azure.

Technical Request:
Create external stage for Network Adjusters that:
- Connects to Azure storage (network adjusters account)
- Reads from container: daily-data-extracts, path: prod2/
- Supports pipe-delimited files with header row
- Lists available files for processing

Upland Standards:
- Database: UPLAND_UTIL
- Schema: NETWORK_ADJUSTERS
- Stage name: NETWORK_ADJUSTERS_CSV_PROD_STG
- Integration name: NETWORK_ADJUSTERS_CSV_INT
- File format: NA_CSV_FORMAT (FIELD_DELIMITER='|', SKIP_HEADER=1)
- Create view: NETWORK_ADJUSTERS_CSV_IMPORT_STAGE_FILES_VW
- Grant SELECT on view to UPLAND_INGEST

Include complete DDL for all objects.
```

### 4. Snowflake Stored Procedure Creation

**Pattern: Query Result Set Procedure**
```
Context: I need a Snowflake stored procedure that queries [table/view] and returns results.

Business Intent: We need to [business purpose] by querying [data] and returning [results].

Technical Request:
Create stored procedure that:
- Accepts parameters: [param1], [param2]
- Queries table: [database.schema.table]
- Filters/transforms data: [logic]
- Returns result set as table
- Includes error handling

Upland Standards:
- Database: UPLAND_UTIL or [specific database]
- Schema: [COMMON, SECURITY, or domain schema]
- Procedure naming: [NAME]_SP or descriptive name
- Use RETURNS TABLE() for result sets
- Include logging/error handling
- Create grants for appropriate roles

Please provide:
1. Stored procedure DDL
2. Example execution
3. Grant statements
```

**Example: File Validation Report Procedure**
```
Context: I need a stored procedure that queries the CSV validation audit log and returns a summary report.

Business Intent: We need to provide a daily summary of CSV-to-table validation results for data quality monitoring.

Technical Request:
Create stored procedure that:
- Accepts parameter: report_date (DATE)
- Queries UPLAND_UTIL.FIVESIGMA.CSV_TABLE_SUM_VALIDATION_LOG
- Filters to specific date
- Groups by source file and validation status
- Returns: source_file, total_validations, passed_count, failed_count, error_count
- Orders by failed_count DESC (failures first)

Upland Standards:
- Database: UPLAND_UTIL
- Schema: FIVESIGMA
- Procedure name: GET_CSV_VALIDATION_SUMMARY_SP
- Returns: TABLE(source_file VARCHAR, total INT, passed INT, failed INT, errors INT)
- Include error handling for invalid dates
- Grant EXECUTE to UPLAND_INGEST and ANALYST_ROLE

Provide complete DDL with usage example.
```

### 5. Airflow DAG Creation

**Pattern: CSV Ingestion Pipeline**
```
Context: I need to create an Airflow DAG for [source system] CSV ingestion pipeline.

Business Intent: We need to automate daily ingestion of [data type] from [source] to support [downstream use case].

Technical Request:
Create DAG that:
- Extracts files from Azure Blob Storage ([container/path])
- Calls Snowflake stored procedure for import
- Archives processed files
- Triggers dbt Cloud job
- Sends failure notifications

Upland Standards:
- DAG file naming: [Source]_CSV_Ingestion_Pipeline_[Env].py
- Use @dag decorator (not context manager)
- Schedule: cron expression in America/Chicago timezone
- Minimum retries: 2 on all tasks
- Include notify_failure callback on all tasks
- Use SQLExecuteQueryOperator for Snowflake
- Use DbtCloudRunJobOperator for dbt
- Connection: UCG_SVC_ASTRONOMER_KP

Workflow:
1. Extract/download files
2. Test Snowflake connection
3. Execute ingestion stored procedure
4. Archive source files
5. Trigger dbt snapshot job

Please confirm this follows Upland Airflow patterns.
```

### 6. Data Validation Task

**Pattern: Adding Validation to Pipeline**
```
Context: I need to add a validation step to the [source] ingestion pipeline.

Business Intent: We need to verify [data quality aspect] before proceeding to downstream processing.

Technical Request:
Add validation task that:
- Reads [configuration/rules]
- Compares [source] to [target]
- Logs results to [audit table]
- Sends alert if [failure condition]
- Blocks downstream tasks if validation fails

Upland Standards:
- Use PythonOperator for validation logic
- Store config in UPLAND_UTIL schema tables
- Log to UPLAND_UTIL audit tables
- Use send_apprise_notification for alerts
- Raise exception to block on failure
- Position: after data load, before dbt/snapshots

Please provide:
1. Python function for validation
2. Task definition
3. Workflow integration
4. Alert message format
```

## dbt-Specific Patterns

### Model References and Dependencies

**Pattern: Multi-Source Integration**
```
I need to create a gold layer model that combines data from:
- Silver layer: [model1], [model2]
- Reference data: [ref_model]

Requirements:
- Join on [keys]
- Apply [business logic]
- Output to gold schema: [schema_name]

Use dbt ref() for dependencies and follow Upland gold layer naming.
```

### Using Macros as CTEs

**Pattern: Reusable Business Logic**
```
I have a complex calculation for [business metric] that needs to be used in multiple models.

Create a dbt macro that:
- Accepts parameters: [params]
- Returns: SELECT statement (not compiled table)
- Can be used in WITH clause as CTE
- Implements: [business logic]

This way we can reuse it like:
WITH calculated_data AS (
  {{ my_macro_name(params) }}
)
SELECT * FROM calculated_data...
```

### Custom Tests

**Pattern: Data Quality Test**
```
I need a custom dbt test to validate [business rule].

Requirements:
- Test should check [condition]
- Apply only to [model type or specific models]
- Store failures: true
- Severity: error

Follow pattern of our existing tests: unique_uid, valid_from_greater_than_valid_to, field_is_null
```

## Snowflake-Specific Patterns

### Permission Management

**Pattern: Granting Access**
```
I need to grant [read/write] access to [database/schema] for [role].

Use our standard permission procedures:
- SP_GRANT_READ_PERMS for SELECT access
- SP_GRANT_READWRITE_PERMS for full access

Provide the CALL statement with correct parameters.
```

### CSV Import Stored Procedure

**Pattern: Using CSV_IMPORT_V2_SP**
```
I need to import CSV file [filename] to table [table_name].

Requirements:
- Auto-detect schema with INFER_SCHEMA
- Expand NUMBER columns to prevent overflow
- Log import to audit table
- Use existing stage: [stage_name]

Provide CALL statement for CSV_IMPORT_V2_SP with all required parameters.
```

## Airflow-Specific Patterns

### Task Dependencies

**Pattern: Parallel Tasks with Convergence**
```
I have tasks [task_a] and [task_b] that can run in parallel after [task_upstream],
then [task_downstream] needs both to complete.

Show me the dependency chain using:
- >> operator for sequential
- [list] for parallel
- chain() if complex
```

### Error Handling

**Pattern: Validation with Blocking**
```
My validation task needs to:
- Run validation logic
- Log results regardless of pass/fail
- Send notification on failure
- Raise exception to block downstream if failed
- Allow retry once

Implement proper error handling and notification pattern.
```

## Anti-Patterns (What NOT to Do)

### ❌ Too Vague for Data Engineering
"Create a dbt model for claims"
- Which layer? Bronze, silver, gold?
- Which source systems?
- Hub, satellite, or mart?
- What business logic?

### ❌ Ignoring Architecture
"Build a table that joins everything"
- Violates medallion architecture
- Skips bronze/silver layers
- No SCD Type 2 tracking
- Not following Data Vault

### ❌ No Naming Convention
"Make a new table called data_table"
- Doesn't follow Upland naming
- No layer indication (stg_, pbi_, etc.)
- Not clear what data it contains

### ❌ Missing Dependencies
"Create a gold layer model" (without ref() to silver)
- dbt won't know dependencies
- Won't build in correct order
- Breaks lineage

### ❌ Hardcoded Environments
"Use PROD_UPLAND_GOLD_DB"
- Won't work in DEV environment
- Should use {{ env_var("DBT_GOLD_DB","DEV_UPLAND_GOLD_DB") }}

## Quick Reference

**Every data engineering prompt should answer:**
1. What layer? (Bronze/Silver/Gold)
2. What technology? (dbt/Snowflake/Airflow)
3. What business domain?
4. What source systems?
5. What Upland patterns apply?

**Every prompt should reference:**
1. Naming conventions
2. Existing similar models/DAGs/procedures
3. Required macros or utilities
4. Schema and database locations
5. Roles and permissions needed

**Every prompt should avoid:**
1. Skipping architecture layers
2. Hardcoding environment-specific values
3. Ignoring SCD Type 2 requirements
4. Missing audit/logging
5. Forgetting grants and permissions

## Measuring Prompt Effectiveness

A good Upland data engineering prompt results in code that:
- ✅ Follows medallion + Data Vault architecture
- ✅ Uses correct naming conventions
- ✅ References appropriate macros and utilities
- ✅ Includes proper SCD Type 2 tracking (where needed)
- ✅ Has environment-aware configuration
- ✅ Includes audit logging
- ✅ Has proper grants and permissions
- ✅ Integrates with existing patterns

If you're not getting these results, refine your prompts using patterns from this guide.
