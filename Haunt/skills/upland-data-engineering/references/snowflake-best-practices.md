# Snowflake Best Practices for Upland EDP

This document outlines best practices for Snowflake development at Upland Capital Group, focusing on objects NOT managed by dbt (stored procedures, stages, integrations, grants) and how they integrate with the dbt-managed medallion architecture.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Database Organization](#database-organization)
- [Object Management Strategy](#object-management-strategy)
- [External Stages and Integrations](#external-stages-and-integrations)
- [Schema Evolution](#schema-evolution)
- [Stored Procedures](#stored-procedures)
- [Security and Permissions](#security-and-permissions)
- [Performance Optimization](#performance-optimization)
- [Audit and Logging](#audit-and-logging)
- [Development Workflow](#development-workflow)

---

## Architecture Overview

### Division of Responsibility

**dbt Cloud Manages:**
- All transformation logic (models)
- SCD Type 2 snapshots
- Data quality tests
- Documentation
- Medallion layer tables/views (Bronze, Silver, Gold)

**Snowflake (Manual Management):**
- External storage integrations
- External stages
- File formats
- Stored procedures (CSV import, permissions, utilities)
- Audit tables
- Non-dbt utility tables
- Grants and permissions
- File discovery views

### Database Structure

```
PROD_UPLAND_BRONZE_DB/     # dbt-managed bronze layer
  └── FIVESIGMA/
  └── NETWORK_ADJUSTERS_2/
  └── SFDC/

PROD_UPLAND_SILVER_DB/     # dbt-managed silver layer (Data Vault)
  └── vault/
  └── stage/
  └── reference/

PROD_UPLAND_GOLD_DB/       # dbt-managed gold layer (Analytics)
  └── claim_reporting/
  └── finance_reporting/
  └── pbi_uw360/

UPLAND_UTIL/               # NOT dbt-managed (Snowflake objects)
  ├── COMMON/              # Shared procedures (CSV_IMPORT_V2_SP)
  ├── SECURITY/            # Permission management procedures
  ├── AUDIT/               # Audit logging tables
  ├── FIVESIGMA/           # FiveSigma stages, formats, views
  └── NETWORK_ADJUSTERS/   # Network Adjusters stages, formats, views

UPLAND_MAINTENANCE/        # Admin procedures
  └── SECURITY/            # Administrative security procedures
```

---

## Database Organization

### UPLAND_UTIL Database

**Purpose**: House all Snowflake objects that are NOT managed by dbt

**Schema Organization:**
- **COMMON**: Shared utility procedures used across domains
- **SECURITY**: Permission management procedures
- **AUDIT**: Audit and logging tables
- **[SOURCE_NAME]**: Source-specific stages, formats, views

**Best Practices:**
1. Keep dbt and Snowflake objects separate
2. Use UPLAND_UTIL for all non-transformation objects
3. Organize by functional purpose (security, audit) or source system
4. Document all objects with COMMENT statements

### Environment Conventions

| Environment | Database Pattern | Usage |
|-------------|------------------|-------|
| **DEV** | `DEV_UPLAND_*_DB` | Development and testing |
| **TEST** | `TEST_UPLAND_*_DB` | QA and validation |
| **PROD** | `PROD_UPLAND_*_DB` | Production workloads |

**Note**: UPLAND_UTIL and UPLAND_MAINTENANCE are shared across environments

---

## Object Management Strategy

### What Goes Where

#### dbt-Managed (in medallion databases)
✅ Tables for data transformation
✅ Views for business logic
✅ Snapshots for SCD Type 2
✅ Tests for data quality
✅ Documentation

#### Snowflake-Managed (in UPLAND_UTIL/UPLAND_MAINTENANCE)
✅ External stages
✅ Storage integrations
✅ File formats
✅ Stored procedures
✅ Audit tables
✅ Permission grants
✅ File discovery views

### Repository Organization

Store Snowflake DDL in version control:

```
UCG.DataEngineering.Snowflake/
├── UPLAND_UTIL/
│   ├── COMMON/
│   │   ├── procedures/
│   │   │   └── CSV_IMPORT_V2_SP.sql
│   │   └── grants/
│   ├── FIVESIGMA/
│   │   ├── integrations_stages/
│   │   ├── formats/
│   │   ├── views/
│   │   ├── tables/
│   │   └── grants/
│   └── NETWORK_ADJUSTERS/
└── docs/
```

---

## External Stages and Integrations

### Azure Blob Storage Integration Pattern

**Step 1: Create Storage Integration**

```sql
USE ROLE ACCOUNTADMIN;

CREATE STORAGE INTEGRATION IF NOT EXISTS NETWORK_ADJUSTERS_CSV_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE
  AZURE_TENANT_ID = 'your-tenant-id'
  STORAGE_ALLOWED_LOCATIONS = (
    'azure://storageaccount.blob.core.windows.net/container/'
  );

-- Retrieve Azure consent URL
DESC STORAGE INTEGRATION NETWORK_ADJUSTERS_CSV_INT;
```

**Step 2: Grant Azure Permissions**

Use the `AZURE_CONSENT_URL` and `AZURE_MULTI_TENANT_APP_NAME` from DESC output to grant permissions in Azure Portal.

**Step 3: Create External Stage**

```sql
USE ROLE SYSADMIN;

CREATE STAGE IF NOT EXISTS UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG
  STORAGE_INTEGRATION = NETWORK_ADJUSTERS_CSV_INT
  URL = 'azure://storageaccount.blob.core.windows.net/container/prod2/'
  FILE_FORMAT = UPLAND_UTIL.NETWORK_ADJUSTERS.NA_CSV_FORMAT;

COMMENT ON STAGE UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG IS
  'External stage for Network Adjusters CSV files delivered daily to Azure Blob Storage';
```

**Step 4: Create File Format**

```sql
CREATE FILE FORMAT IF NOT EXISTS UPLAND_UTIL.NETWORK_ADJUSTERS.NA_CSV_FORMAT
  TYPE = CSV
  FIELD_DELIMITER = '|'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TRIM_SPACE = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  EMPTY_FIELD_AS_NULL = TRUE;
```

**Step 5: Create File Discovery View**

```sql
CREATE OR REPLACE VIEW UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_IMPORT_STAGE_FILES_VW AS
SELECT
    metadata$filename AS filename,
    metadata$file_row_number AS file_row_number,
    metadata$file_last_modified AS file_last_modified
FROM @UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG
(FILE_FORMAT => UPLAND_UTIL.NETWORK_ADJUSTERS.NA_CSV_FORMAT);
```

### Stage Best Practices

1. **Naming Convention**: `[SOURCE]_[TYPE]_[ENV]_STG`
   - Example: `FIVESIGMA_CSV_PROD_STG`

2. **Integration Naming**: `[SOURCE]_[TYPE]_INT`
   - Example: `NETWORK_ADJUSTERS_CSV_INT`

3. **Always include file format** in stage definition

4. **Create file discovery views** for Airflow/orchestration

5. **Document purpose** with COMMENT statements

6. **Grant appropriate permissions** immediately after creation

---

## Schema Evolution

Snowflake supports automatic schema evolution during COPY operations, allowing new columns in source files to be added automatically.

### Enabling Schema Evolution

**1. Enable on Target Table:**

```sql
ALTER TABLE PROD_UPLAND_BRONZE_DB.RIPRO.STG_CASH
    SET ENABLE_SCHEMA_EVOLUTION = TRUE;
```

**2. Configure File Format:**

```sql
CREATE OR REPLACE FILE FORMAT PROD_UPLAND_BRONZE_DB.RIPRO.RIPRO_CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    PARSE_HEADER = TRUE              -- Required for schema evolution
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE  -- Allows new columns
    TRIM_SPACE = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', '', 'NA', 'N/A');
```

**3. Use MATCH_BY_COLUMN_NAME in COPY:**

```sql
COPY INTO PROD_UPLAND_BRONZE_DB.RIPRO.STG_CASH
FROM @RIPRO_AZURE_STAGE
FILE_FORMAT = (FORMAT_NAME = 'RIPRO_CSV_FORMAT')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE  -- Maps by name, not position
ON_ERROR = 'ABORT_STATEMENT';
```

### Key Settings

| Setting | Value | Purpose |
|---------|-------|---------|
| `ENABLE_SCHEMA_EVOLUTION` | TRUE | Auto-add new columns to table |
| `PARSE_HEADER` | TRUE | Read column names from CSV header |
| `ERROR_ON_COLUMN_COUNT_MISMATCH` | FALSE | Don't fail on new columns |
| `MATCH_BY_COLUMN_NAME` | CASE_INSENSITIVE | Map CSV columns to table by name |

### Best Practices

1. **Use generous data types** to prevent overflow:
   - Text: `VARCHAR(16777216)` (max)
   - Integers: `NUMBER(38,0)`
   - Decimals: `NUMBER(38,10)`

2. **Always include metadata columns**:
   ```sql
   _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
   _SOURCE_FILE VARCHAR(500)
   ```

3. **Monitor new columns**: Check `INFORMATION_SCHEMA.COLUMNS` after loads

4. **Use with dbt snapshots**: Snapshots use timestamp strategy for auto-evolution

### When to Use

| Scenario | Use Schema Evolution? |
|----------|----------------------|
| Source adds columns frequently | Yes |
| Fixed schema, strict validation | No |
| Initial development, schema unknown | Yes |
| Production with stable sources | Consider case-by-case |

---

## Stored Procedures

### CSV Import Architecture

Upland uses a **two-tier stored procedure pattern** for CSV imports:

1. **Orchestrator Procedure** (Source-specific)
   - Iterates through files
   - Calls core processor
   - Handles batch orchestration

2. **Core Processor** (Reusable)
   - `CSV_IMPORT_V2_SP` - Dynamic table creation
   - Schema inference with `INFER_SCHEMA`
   - Audit logging

### CSV_IMPORT_V2_SP Pattern

**Core Features:**
- Automatic table creation using `INFER_SCHEMA()`
- Expands NUMBER columns to `NUMBER(38, scale)` to prevent overflow
- Logs all imports to audit table
- Error handling that doesn't stop batch processing

**Usage:**

```sql
CALL UPLAND_UTIL.COMMON.CSV_IMPORT_V2_SP(
    TABLE_NAME => 'PROD_UPLAND_BRONZE_DB.NETWORK_ADJUSTERS_2.STG_CLAIM',
    FILE_NAME => 'claims_20250520.txt',
    FILE_FORMAT_SCHEMA => 'UPLAND_UTIL.NETWORK_ADJUSTERS.NA_CSV_FORMAT_SCHEMA',
    FILE_FORMAT_COPY => 'UPLAND_UTIL.NETWORK_ADJUSTERS.NA_CSV_FORMAT',
    EXTERNAL_STAGE => 'UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG',
    EXTERNAL_INTEGRATION => 'NETWORK_ADJUSTERS_CSV_INT',
    JOB_NAME => 'Network Adjusters Flat File Import',
    IMPORT_LOG => 'UPLAND_UTIL.AUDIT.FILE_INGESTION_LOG'
);
```

### Creating Source-Specific Orchestrator Procedures

**Pattern: File Iterator with Core Processor Call**

```sql
CREATE OR REPLACE PROCEDURE UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_IMPORT()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    file_cursor CURSOR FOR
        SELECT DISTINCT filename
        FROM UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_IMPORT_STAGE_FILES_VW;

    file_name VARCHAR;
    table_name VARCHAR;
    result VARCHAR;
BEGIN
    -- Iterate through files
    FOR file_record IN file_cursor DO
        file_name := file_record.filename;

        -- Determine target table from filename
        table_name := 'PROD_UPLAND_BRONZE_DB.NETWORK_ADJUSTERS_2.STG_' ||
                      SPLIT_PART(file_name, '.', 1);

        -- Call core import procedure
        CALL UPLAND_UTIL.COMMON.CSV_IMPORT_V2_SP(
            TABLE_NAME => :table_name,
            FILE_NAME => :file_name,
            FILE_FORMAT_SCHEMA => 'UPLAND_UTIL.NETWORK_ADJUSTERS.NA_CSV_FORMAT_SCHEMA',
            FILE_FORMAT_COPY => 'UPLAND_UTIL.NETWORK_ADJUSTERS.NA_CSV_FORMAT',
            EXTERNAL_STAGE => 'UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG',
            EXTERNAL_INTEGRATION => 'NETWORK_ADJUSTERS_CSV_INT',
            JOB_NAME => 'Network Adjusters CSV Import',
            IMPORT_LOG => 'UPLAND_UTIL.AUDIT.FILE_INGESTION_LOG'
        );
    END FOR;

    RETURN 'Import completed successfully';
END;
$$;
```

### Query Result Set Procedures

**Pattern: Returning Table Results**

```sql
CREATE OR REPLACE PROCEDURE UPLAND_UTIL.FIVESIGMA.GET_CSV_VALIDATION_SUMMARY_SP(
    REPORT_DATE DATE
)
RETURNS TABLE(
    source_file VARCHAR,
    total_validations INT,
    passed_count INT,
    failed_count INT,
    error_count INT
)
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    result_query VARCHAR;
BEGIN
    result_query := '
        SELECT
            SOURCE_FILE as source_file,
            COUNT(*) as total_validations,
            SUM(CASE WHEN VALIDATION_STATUS = ''PASS'' THEN 1 ELSE 0 END) as passed_count,
            SUM(CASE WHEN VALIDATION_STATUS = ''FAIL'' THEN 1 ELSE 0 END) as failed_count,
            SUM(CASE WHEN VALIDATION_STATUS = ''ERROR'' THEN 1 ELSE 0 END) as error_count
        FROM UPLAND_UTIL.FIVESIGMA.CSV_TABLE_SUM_VALIDATION_LOG
        WHERE DATE(RUNTIME) = ''' || :REPORT_DATE || '''
        GROUP BY SOURCE_FILE
        ORDER BY failed_count DESC
    ';

    -- Return the result set
    RETURN TABLE(result_query);
END;
$$;
```

**Usage:**

```sql
CALL UPLAND_UTIL.FIVESIGMA.GET_CSV_VALIDATION_SUMMARY_SP('2025-10-21');
```

### Stored Procedure Best Practices

1. **Use descriptive names** ending in `_SP`
2. **Document parameters** with COMMENT statements
3. **Include error handling** with BEGIN...EXCEPTION...END blocks
4. **Log operations** to audit tables
5. **Use EXECUTE AS CALLER** for security context
6. **Return meaningful messages** or result sets
7. **Keep procedures focused** - one purpose per procedure
8. **Version control** all procedure DDL

---

## Security and Permissions

### Role-Based Access Control

**Standard Upland Roles:**

| Role | Purpose | Typical Grants |
|------|---------|----------------|
| **UPLAND_INGEST** | Data ingestion execution | SELECT on stages/formats, INSERT on bronze tables |
| **UPLAND_TRANSFORMER** | Data processing (dbt) | SELECT on bronze/silver, CREATE on silver/gold |
| **UPLAND_ADMIN_BOT** | Administrative operations | USAGE on stages, EXECUTE on procedures |
| **ANALYST_ROLE** | Read-only analytics | SELECT on gold layer |
| **SYSADMIN** | Object creation | CREATE objects |
| **SECURITYADMIN** | Grant management | GRANT permissions |

### Permission Management Procedures

#### SP_GRANT_READ_PERMS

Grants SELECT access to database or schema:

```sql
-- Grant read access to entire database
CALL UPLAND_UTIL.SECURITY.SP_GRANT_READ_PERMS(
    'PROD_UPLAND_GOLD_DB',  -- database
    NULL,                    -- schema (NULL = all schemas)
    'ANALYST_ROLE',          -- role
    TRUE                     -- all_schemas flag
);

-- Grant read access to specific schema
CALL UPLAND_UTIL.SECURITY.SP_GRANT_READ_PERMS(
    'PROD_UPLAND_GOLD_DB',  -- database
    'CLAIM_REPORTING',       -- schema
    'ANALYST_ROLE',          -- role
    FALSE                    -- single schema
);
```

**What it grants:**
- USAGE on database and schema
- SELECT on all current tables, views, streams, dynamic tables
- SELECT on all future tables, views, streams, dynamic tables
- READ on all stages
- USAGE on all file formats, procedures, functions

#### SP_GRANT_READWRITE_PERMS

Grants full read/write access:

```sql
CALL UPLAND_UTIL.SECURITY.SP_GRANT_READWRITE_PERMS(
    'DEV_UPLAND_SILVER_DB',
    'vault',
    'UPLAND_TRANSFORMER',
    FALSE
);
```

**What it grants:**
- Everything from SP_GRANT_READ_PERMS, plus:
- INSERT, UPDATE, DELETE on tables
- CREATE on schema

### Manual Grant Pattern

When procedures aren't suitable:

```sql
USE ROLE SECURITYADMIN;

-- Grant stage access
GRANT USAGE ON INTEGRATION NETWORK_ADJUSTERS_CSV_INT TO ROLE UPLAND_INGEST;
GRANT READ ON STAGE UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG TO ROLE UPLAND_INGEST;

-- Grant table access
GRANT SELECT ON TABLE UPLAND_UTIL.FIVESIGMA.CSV_TABLE_SUM_VALIDATION_CONFIG TO ROLE UPLAND_INGEST;
GRANT SELECT, INSERT ON TABLE UPLAND_UTIL.FIVESIGMA.CSV_TABLE_SUM_VALIDATION_LOG TO ROLE UPLAND_INGEST;

-- Grant schema usage
GRANT USAGE ON SCHEMA UPLAND_UTIL.FIVESIGMA TO ROLE UPLAND_INGEST;

-- Grant future objects
GRANT SELECT ON FUTURE TABLES IN SCHEMA UPLAND_UTIL.FIVESIGMA TO ROLE UPLAND_INGEST;
```

### Permission Best Practices

1. **Use roles, not users** for all grants
2. **Apply future grants** to catch new objects
3. **Document grants** in version control
4. **Use SECURITYADMIN role** for granting permissions
5. **Use SYSADMIN role** for creating objects
6. **Test permissions** with target role: `USE ROLE UPLAND_INGEST;`
7. **Grant least privilege** - only what's needed
8. **Create grants immediately** after object creation

---

## Performance Optimization

### Warehouse Sizing

**Upland Standard Warehouses:**

| Warehouse | Size | Purpose |
|-----------|------|---------|
| UCG_ASTRONOMER | Medium | Airflow job execution |
| UCG_DBT | Large | dbt Cloud transformation |
| UCG_LOADING | Medium | CSV ingestion |
| UCG_REPORTING | Small | Ad-hoc queries, Power BI |

### Query Optimization

1. **Use clustering keys** on large tables (>100M rows)
```sql
ALTER TABLE large_fact_table
  CLUSTER BY (date_column, key_column);
```

2. **Leverage search optimization** for point queries
```sql
ALTER TABLE lookup_table
  ADD SEARCH OPTIMIZATION;
```

3. **Use QUALIFY for window functions**
```sql
SELECT *
FROM table
QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY date DESC) = 1;
```

4. **Partition large scans** with date filters
```sql
WHERE date_column >= DATEADD(day, -30, CURRENT_DATE())
```

### Storage Optimization

1. **Use transient tables** for staging
```sql
CREATE TRANSIENT TABLE staging_table AS ...
```

2. **Set retention time** appropriately
```sql
CREATE TABLE audit_log (...)
DATA_RETENTION_TIME_IN_DAYS = 7;
```

3. **Drop unused tables** regularly
4. **Monitor table storage** with `INFORMATION_SCHEMA.TABLE_STORAGE_METRICS`

---

## Audit and Logging

### Audit Table Pattern

**Standard Audit Table Structure:**

```sql
CREATE TABLE IF NOT EXISTS UPLAND_UTIL.AUDIT.FILE_INGESTION_LOG (
    LOG_ID NUMBER(38,0) AUTOINCREMENT,
    JOB_NAME VARCHAR(500) NOT NULL,
    RUNTIME TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    FILE_NAME VARCHAR(500),
    TABLE_NAME VARCHAR(500),
    ROWS_LOADED NUMBER(38,0),
    STATUS VARCHAR(50),  -- SUCCESS, FAILED, PARTIAL
    ERROR_MESSAGE VARCHAR(5000),
    CONSTRAINT PK_FILE_INGESTION_LOG PRIMARY KEY (LOG_ID)
);
```

### Logging Best Practices

1. **Log all imports** to audit tables
2. **Include timestamps** in CST/CDT timezone
3. **Capture row counts** for validation
4. **Store error messages** for debugging
5. **Retain logs** for compliance period (90+ days)
6. **Query logs regularly** for monitoring

### Query History

Use Snowflake's query history:

```sql
-- Find slow queries
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE EXECUTION_TIME > 60000  -- 60 seconds
  AND START_TIME >= DATEADD(day, -7, CURRENT_TIMESTAMP())
ORDER BY EXECUTION_TIME DESC;

-- Find failed queries
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE ERROR_CODE IS NOT NULL
  AND START_TIME >= DATEADD(day, -1, CURRENT_TIMESTAMP());
```

---

## Development Workflow

### Creating New Snowflake Objects

1. **Develop DDL locally** in SQL editor
2. **Test in DEV environment** first
3. **Document with COMMENT** statements
4. **Store in version control** (UCG.DataEngineering.Snowflake repo)
5. **Create grants** using SECURITYADMIN role
6. **Test with target role** to verify permissions
7. **Promote to PROD** after validation

### Standard Object Creation Workflow

```sql
-- Step 1: Create object with SYSADMIN
USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE ...;

-- Step 2: Add comments
COMMENT ON PROCEDURE ... IS 'Description of purpose';

-- Step 3: Apply grants with SECURITYADMIN
USE ROLE SECURITYADMIN;
GRANT EXECUTE ON PROCEDURE ... TO ROLE UPLAND_INGEST;

-- Step 4: Test with target role
USE ROLE UPLAND_INGEST;
CALL procedure_name(...);
```

### Testing Procedures

```sql
-- Test stage access
USE ROLE UPLAND_INGEST;
LIST @UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG;

-- Test file discovery
SELECT * FROM UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_IMPORT_STAGE_FILES_VW LIMIT 10;

-- Test procedure execution
CALL UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_IMPORT();

-- Check audit logs
SELECT * FROM UPLAND_UTIL.AUDIT.FILE_INGESTION_LOG
WHERE JOB_NAME = 'Network Adjusters CSV Import'
ORDER BY RUNTIME DESC
LIMIT 10;
```

### Rollback Strategy

1. **Keep previous version** of procedure DDL
2. **Use CREATE OR REPLACE** for safe updates
3. **Test thoroughly** in DEV first
4. **Have rollback script** ready
5. **Monitor execution** after deployment

---

## Common Patterns

### Pattern: CSV Import Pipeline

Complete setup for new CSV source:

```sql
-- 1. Create storage integration (ACCOUNTADMIN)
CREATE STORAGE INTEGRATION [SOURCE]_CSV_INT ...;

-- 2. Grant Azure permissions (Azure Portal)
-- Use AZURE_CONSENT_URL from DESC STORAGE INTEGRATION

-- 3. Create file format (SYSADMIN)
CREATE FILE FORMAT UPLAND_UTIL.[SOURCE].[SOURCE]_CSV_FORMAT
  TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1 ...;

-- 4. Create external stage (SYSADMIN)
CREATE STAGE UPLAND_UTIL.[SOURCE].[SOURCE]_CSV_PROD_STG
  STORAGE_INTEGRATION = [SOURCE]_CSV_INT
  URL = 'azure://...'
  FILE_FORMAT = UPLAND_UTIL.[SOURCE].[SOURCE]_CSV_FORMAT;

-- 5. Create file discovery view (SYSADMIN)
CREATE VIEW UPLAND_UTIL.[SOURCE].[SOURCE]_CSV_IMPORT_STAGE_FILES_VW AS
  SELECT metadata$filename AS filename FROM @UPLAND_UTIL.[SOURCE].[SOURCE]_CSV_PROD_STG;

-- 6. Create orchestrator procedure (SYSADMIN)
CREATE PROCEDURE UPLAND_UTIL.[SOURCE].[SOURCE]_CSV_IMPORT() ...;

-- 7. Apply grants (SECURITYADMIN)
GRANT READ ON STAGE ... TO ROLE UPLAND_INGEST;
GRANT SELECT ON VIEW ... TO ROLE UPLAND_INGEST;
GRANT EXECUTE ON PROCEDURE ... TO ROLE UPLAND_INGEST;
```

### Pattern: Validation Audit Table

```sql
-- 1. Create audit table (SYSADMIN)
CREATE TABLE UPLAND_UTIL.[SCHEMA].[AUDIT_TABLE_NAME] (
    LOG_ID NUMBER(38,0) AUTOINCREMENT,
    JOB_NAME VARCHAR(500) NOT NULL,
    RUNTIME TIMESTAMP_NTZ NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    -- validation-specific columns
    VALIDATION_STATUS VARCHAR(50),
    CONSTRAINT PK_[TABLE_NAME] PRIMARY KEY (LOG_ID)
);

-- 2. Add comments
COMMENT ON TABLE ... IS 'Purpose of audit table';

-- 3. Grant access (SECURITYADMIN)
GRANT SELECT, INSERT ON TABLE ... TO ROLE UPLAND_INGEST;
```

---

## Troubleshooting

### Common Issues

**Issue: Permission denied on stage**
```sql
-- Solution: Check grants
SHOW GRANTS ON STAGE UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG;
-- Apply missing grants
GRANT READ ON STAGE ... TO ROLE UPLAND_INGEST;
```

**Issue: Storage integration not working**
```sql
-- Solution: Verify Azure permissions
DESC STORAGE INTEGRATION NETWORK_ADJUSTERS_CSV_INT;
-- Re-authorize in Azure Portal using AZURE_CONSENT_URL
```

**Issue: File not found in stage**
```sql
-- Solution: List files in stage
LIST @UPLAND_UTIL.NETWORK_ADJUSTERS.NETWORK_ADJUSTERS_CSV_PROD_STG;
-- Check path and integration
```

**Issue: Procedure execution fails**
```sql
-- Solution: Check audit logs
SELECT * FROM UPLAND_UTIL.AUDIT.FILE_INGESTION_LOG
WHERE STATUS = 'FAILED'
ORDER BY RUNTIME DESC;
-- Review error messages
```

---

## Checklist for New Objects

### External Stage Setup
- [ ] Storage integration created (ACCOUNTADMIN)
- [ ] Azure permissions granted via consent URL
- [ ] File format defined
- [ ] External stage created
- [ ] File discovery view created
- [ ] All objects documented with COMMENT
- [ ] Grants applied (SECURITYADMIN)
- [ ] Tested with target role
- [ ] DDL stored in version control

### Stored Procedure Setup
- [ ] Procedure logic tested
- [ ] Parameters documented
- [ ] Error handling included
- [ ] Audit logging implemented
- [ ] Comments added
- [ ] Grants applied
- [ ] Tested with target role
- [ ] DDL stored in version control

---

## Additional Resources

- **Snowflake Docs**: https://docs.snowflake.com
- **Azure Integration**: https://docs.snowflake.com/en/user-guide/data-load-azure
- **Stored Procedures**: https://docs.snowflake.com/en/sql-reference/stored-procedures
- **Security**: https://docs.snowflake.com/en/user-guide/security-access-control
