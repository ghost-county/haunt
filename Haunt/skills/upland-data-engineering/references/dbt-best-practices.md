# dbt Best Practices for Upland EDP

This document outlines best practices for dbt Cloud development at Upland Capital Group, focusing on our medallion + Data Vault 2.0 architecture.

## Table of Contents
- [Architecture Principles](#architecture-principles)
- [Project Organization](#project-organization)
- [Model Development](#model-development)
- [Naming Conventions](#naming-conventions)
- [Macros and Reusability](#macros-and-reusability)
- [Sources and References](#sources-and-references)
- [Testing Strategy](#testing-strategy)
- [Documentation](#documentation)
- [Environment Management](#environment-management)
- [Performance Optimization](#performance-optimization)

---

## Architecture Principles

### Medallion + Data Vault Architecture

Upland EDP implements a **three-layer medallion architecture** with **Data Vault 2.0** in the silver layer:

```
Bronze Layer (Raw)
    ↓
Silver Layer (Integrated - Data Vault 2.0)
    ↓
Gold Layer (Analytics)
```

#### Bronze Layer
- **Purpose**: Raw, minimally transformed data from source systems
- **Transformation**: Direct mappings, type casting, basic cleaning
- **Managed by**: dbt snapshots
- **SCD Type**: Type 2 via snapshots (dbt_valid_from, dbt_valid_to)

#### Silver Layer
- **Purpose**: Integrated, historized business entities using Data Vault
- **Pattern**: Hub-and-spoke (hubs, satellites, links)
- **SCD Type**: Type 2 with valid_from/valid_to
- **Organization**: 13+ business domains (broker, claim, policy, quote, etc.)

#### Gold Layer
- **Purpose**: Business-ready analytics marts and dashboards
- **Organization**: 15+ analytical use cases
- **Naming**: Power BI datasets prefixed with `pbi_`

### Data Vault 2.0 Patterns

#### Hubs (Business Keys)
- Store unique business identifiers
- Minimal attributes (just the key)
- Example: `claim_hub`, `policy_hub`, `claimant_hub`

#### Satellites (Attributes)
- Descriptive information about hubs
- Change tracking with valid_from/valid_to
- Example: `claim_payment_hub`, `loss_reserve_hub`

#### Links (Relationships)
- Many-to-many relationships between hubs
- Association tables

**All vault tables must include:**
- `valid_from` - Start of record validity
- `valid_to` - End of record validity (NULL or 2099-12-31 for current)
- `change_event` - INSERT, UPDATE, or DELETE
- `record_source` - Origin system identifier

---

## Project Organization

### Directory Structure

```
models/
├── bronze_layer/          # Raw source mappings
│   ├── fivesigma/
│   ├── network_adjusters/
│   └── sfdc/
├── silver_layer/          # Data Vault 2.0
│   ├── broker/
│   ├── claim/
│   ├── policy/
│   ├── quote/
│   └── [10+ other domains]
└── gold_layer/            # Analytics marts
    ├── claim_reporting/
    ├── finance_reporting/
    ├── pbi_uw360/
    └── [12+ other marts]

snapshots/                 # SCD Type 2 snapshots
├── fivesigma_stg_snapshots.yml
├── network_adjusters_2_snapshots.yml
└── claim_notes_snapshots.yml

tests/                     # Data quality tests
├── generic/              # Reusable test definitions
│   ├── unique_uid.sql
│   ├── valid_from_greater_than_valid_to.sql
│   └── field_is_null.sql
└── singular/             # One-off business logic tests

macros/                    # Custom transformation macros
├── generate_schema_name.sql
├── vault_valid_to.sql
├── convert_utc_to_central_tz.sql
└── [7+ other macros]
```

### File Organization Best Practices

1. **Group by business domain first**, then by layer
2. **Separate staging models** from final models
3. **Use subfolders** for related models (e.g., `claim_reporting/`)
4. **Keep related models together** (hub + its satellites)

---

## Model Development

### Model Configuration

Every model should have explicit configuration:

```sql
{{
  config(
    materialized='table',  -- or 'view', 'incremental'
    schema='vault',        -- schema within database
    database=env_var("DBT_SILVER_DB","DEV_UPLAND_SILVER_DB"),
    tags=['silver', 'claim', 'daily'],
    alias='claim_payment_hub'  -- override model name if needed
  )
}}
```

### Model Template Structure

```sql
-- Model configuration
{{
  config(
    materialized='table',
    schema='vault',
    database=env_var("DBT_SILVER_DB","DEV_UPLAND_SILVER_DB")
  )
}}

-- CTEs for source data
with source_data as (
    select * from {{ ref('stg_source_table') }}
),

-- Business logic transformations
transformed as (
    select
        id as entity_uid,
        {{ convert_utc_to_central_tz('created_date') }} as valid_from,
        {{ vault_valid_to('id', 'null') }} as valid_to,
        change_event,
        record_source,
        -- other columns
    from source_data
),

-- Final select
final as (
    select * from transformed
)

select * from final
```

### Staging Models

Staging models (`stg_` prefix) prepare source data for integration:

```sql
with source as (
    select * from {{ source('fivesigma', 'stg_claim') }}
),

renamed as (
    select
        id::varchar as claim_id,
        {{ convert_utc_to_central_tz('created_date') }} as created_timestamp,
        {{ convert_indicator_to_boolean('is_active') }} as is_active_flag,
        {{ convert_empty_to_null('description') }} as description,
        'FIVESIGMA' as record_source
    from source
)

select * from renamed
```

**Staging model responsibilities:**
- Column renaming to standard names
- Type casting
- Basic transformations (timezone, indicators, etc.)
- Adding metadata (record_source)
- **NOT** business logic or joins

### Union Relations Pattern

For multi-source integration:

```sql
with combined_view as (
    {{
      dbt_utils.union_relations(
        relations=[
          ref('stg_telenet_claim_hub'),
          ref('stg_N1_claim_change_event')
        ]
      )
    }}
)

select * from combined_view
```

### Incremental Models

Use for large fact tables:

```sql
{{
  config(
    materialized='incremental',
    unique_key='transaction_id',
    on_schema_change='append_new_columns'
  )
}}

select * from source_data

{% if is_incremental() %}
  where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
```

**When to use incremental:**
- Large transaction/event tables (>10M rows)
- Daily or more frequent loads
- Append-only or upsert patterns

**When NOT to use incremental:**
- Small dimension tables
- Full refresh needed often
- Complex joins (hard to get incremental logic right)

---

## Naming Conventions

### Model Naming

| Layer | Type | Pattern | Example |
|-------|------|---------|---------|
| Silver | Staging | `stg_[source]_[entity]` | `stg_telenet_claim_change_event` |
| Silver | Hub | `[entity]_hub` | `claim_hub`, `claimant_hub` |
| Silver | Satellite | `[entity]_[attribute]_hub` | `claim_payment_hub` |
| Gold | Staging | `stg_[domain]_[entity]` | `stg_marketstance_sales_size` |
| Gold | Power BI | `pbi_[dashboard]` | `pbi_submission_inbox_current` |
| Gold | Mart | `[domain]_[purpose]` | `premium_production_dashboard` |

### Column Naming

- Use **snake_case** for all columns
- Suffix boolean flags with `_flag` or `_indicator`
- Suffix timestamps with `_timestamp` or `_date`
- Use `_uid` for surrogate keys
- Use `_id` for natural keys

**Examples:**
```sql
claim_uid           -- Surrogate key
claim_number        -- Natural key
is_active_flag      -- Boolean
created_timestamp   -- Timestamp
policy_effective_date  -- Date only
```

### Schema Naming

Schemas are determined by `config(schema='...')` and the `generate_schema_name` macro:

- **DEV environment**: Prefixes with developer name (e.g., `MICHAEL_vault`)
- **PROD/TEST environment**: Uses schema name directly (e.g., `vault`)

**Standard schemas:**
- `stage` - Staging models
- `vault` - Data Vault tables
- `reference` - Reference/dimension data
- `[domain]` - Gold layer domain schemas

---

## Macros and Reusability

### Using Existing Upland Macros

#### Timezone Conversion
```sql
-- For timestamp columns
{{ convert_utc_to_central_tz('created_date') }}

-- For non-timestamp types
{{ convert_utc_to_central_ntz('date_string') }}
```

#### Data Vault SCD Type 2
```sql
-- Calculate valid_to for vault tables
{{ vault_valid_to('claim_uid', 'null') }}
```

#### Data Type Conversions
```sql
-- Boolean to Y/N indicator
{{ convert_boolean_to_indicator('is_active') }}

-- Y/N indicator to boolean
{{ convert_indicator_to_boolean('active_yn') }}

-- Clean and convert string numbers
{{ clean_string_number_to_number('amount_string') }}
```

#### Data Cleaning
```sql
-- Empty string to NULL
{{ convert_empty_to_null('description') }}

-- Whitespace to NULL
{{ convert_to_null_if_blank('notes') }}
```

#### Power BI Utilities
```sql
-- Current timestamp for Power BI refresh
{{ pbi_timestamp() }}
```

### Creating Reusable Macros

#### Pattern: Macro as SQL Generator (for CTE use)

```sql
-- macros/calculate_premium.sql
{% macro calculate_premium(policy_table, effective_date) %}
    select
        policy_id,
        base_premium * rate_factor as calculated_premium,
        '{{ effective_date }}' as calculation_date
    from {{ policy_table }}
    where effective_date = '{{ effective_date }}'
{% endmacro %}
```

**Usage in model:**
```sql
with premium_calc as (
    {{ calculate_premium(ref('policies'), '2025-01-01') }}
),

final as (
    select * from premium_calc
    where calculated_premium > 0
)

select * from final
```

#### Pattern: Macro as Value Generator

```sql
-- macros/get_current_rate.sql
{% macro get_current_rate(rate_type) %}
    (select rate from {{ ref('rate_table') }}
     where rate_type = '{{ rate_type }}'
     and current_date between effective_date and expiration_date
     limit 1)
{% endmacro %}
```

**Usage:**
```sql
select
    policy_id,
    premium * {{ get_current_rate('commission') }} as commission_amount
from policies
```

### Macro Best Practices

1. **Document macro parameters** with comments
2. **Return complete SQL statements** for CTE use
3. **Use Jinja variables** for dynamic logic
4. **Test macros thoroughly** across models
5. **Keep macros focused** - one purpose per macro
6. **Use ref() and source()** within macros when referencing models

---

## Sources and References

### Defining Sources

Sources represent raw data in Snowflake:

```yaml
# models/bronze_layer/sources.yml
version: 2

sources:
  - name: fivesigma
    database: PROD_UPLAND_BRONZE_DB
    schema: FIVESIGMA
    tables:
      - name: CLAIM
        description: FiveSigma claim snapshot data
        loaded_at_field: DBT_UPDATED_AT
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}
        columns:
          - name: ID
            description: Unique claim identifier
            tests:
              - not_null
              - unique
```

**Source best practices:**
- Define freshness checks for critical sources
- Document business meaning of tables
- Add tests on source columns
- Use `loaded_at_field` for freshness monitoring

### Using Sources in Models

```sql
select * from {{ source('fivesigma', 'CLAIM') }}
```

**Benefits:**
- dbt tracks lineage
- Freshness checks run automatically
- Easy to identify upstream dependencies

### Using References

Reference other dbt models:

```sql
select * from {{ ref('stg_fivesigma_claim') }}
```

**Best practices:**
- Always use `ref()`, never hardcode table names
- dbt builds models in correct dependency order
- Enables impact analysis (what breaks if I change this?)

### Cross-Database References

```sql
-- Reference model in different database
select * from {{ ref('bronze_claim') }}

-- dbt handles database routing based on environment
-- DEV: DEV_UPLAND_SILVER_DB.schema.model
-- PROD: PROD_UPLAND_SILVER_DB.schema.model
```

---

## Testing Strategy

### Test Types

1. **Schema Tests** - Column-level tests defined in YAML
2. **Generic Tests** - Reusable custom test definitions
3. **Singular Tests** - One-off SQL-based tests

### Schema Tests (Built-in)

```yaml
models:
  - name: claim_hub
    columns:
      - name: claim_uid
        tests:
          - unique
          - not_null
      - name: claim_number
        tests:
          - not_null
      - name: valid_from
        tests:
          - not_null
```

### Custom Generic Tests

Upland has 3 custom generic tests:

#### 1. unique_uid (SCD Type 2 Uniqueness)
Tests uniqueness for current records only:

```yaml
- name: claim_uid
  tests:
    - unique_uid  # Only checks where valid_to IS NULL
```

#### 2. valid_from_greater_than_valid_to (Temporal Logic)
Ensures temporal consistency:

```yaml
- name: valid_from
  tests:
    - valid_from_greater_than_valid_to
```

#### 3. field_is_null (Required Field Validation)
Checks required fields in current records:

```yaml
- name: claim_number
  tests:
    - field_is_null  # Fails if NULL in current records
```

### Singular Tests

For complex business logic:

```sql
-- tests/singular/test_claim_payment_total.sql
-- Validate that claim payment totals match expected values

with claim_totals as (
    select
        claim_id,
        sum(payment_amount) as total_payments
    from {{ ref('claim_payments') }}
    group by claim_id
),

validation as (
    select
        c.claim_id,
        c.total_incurred,
        ct.total_payments
    from {{ ref('claims') }} c
    join claim_totals ct on c.claim_id = ct.claim_id
    where abs(c.total_incurred - ct.total_payments) > 0.01  -- Allow penny rounding
)

-- Test fails if this returns any rows
select * from validation
```

### Test Configuration

All tests store failures globally:

```yaml
# dbt_project.yml
tests:
  +store_failures: true  # Store failing rows in database
  +severity: error       # error or warn
```

**Best practices:**
- Test all primary keys (unique + not_null)
- Test foreign key relationships
- Test critical business rules
- Use appropriate severity (error blocks, warn alerts)
- Review stored test failures regularly

---

## Documentation

### Model Documentation

```yaml
models:
  - name: claim_hub
    description: >
      Hub table containing unique claim identifiers from all source systems.
      Implements Data Vault 2.0 pattern with SCD Type 2 historization.
    columns:
      - name: claim_uid
        description: Surrogate key for claim entity
      - name: claim_number
        description: Business key - claim number from source system
      - name: valid_from
        description: Timestamp when this version of the record became active
      - name: valid_to
        description: Timestamp when this version of the record became inactive (NULL for current)
      - name: change_event
        description: Type of change - INSERT, UPDATE, or DELETE
      - name: record_source
        description: Source system identifier (FIVESIGMA, TELENET, etc.)
```

### Inline Documentation

Use dbt descriptions in models:

```sql
{{
  config(
    materialized='table',
    description='Gold layer dashboard for premium production reporting'
  )
}}
```

### Exposure Documentation

Document downstream consumers:

```yaml
exposures:
  - name: premium_production_dashboard
    type: dashboard
    maturity: high
    url: https://app.powerbi.com/groups/.../reports/...
    description: >
      Premium domain focused dashboard for production reporting.
      Used by underwriting leadership for daily decision making.
    depends_on:
      - ref('premium_production_dashboard')
      - ref('pbi_uw360')
    owner:
      name: Jeffrey Gottlieb
      email: jgottlieb@uplandcapgroup.com
```

### Documentation Best Practices

1. **Describe business meaning**, not just technical details
2. **Document derivations** and complex calculations
3. **Explain SCD Type 2 logic** for vault tables
4. **Link to business glossary** or wiki if available
5. **Keep documentation up to date** with model changes

---

## Environment Management

### Environment Variables

Use environment variables for environment-specific configuration:

```sql
{{
  config(
    database=env_var("DBT_GOLD_DB", "DEV_UPLAND_GOLD_DB")
  )
}}
```

**Standard Upland environment variables:**
- `DBT_GOLD_DB` - Gold layer database
- `DBT_SILVER_DB` - Silver layer database
- `DBT_BRONZE_DB` - Bronze layer database (rarely used, mostly snapshots)

### Database Naming

- **DEV**: `DEV_UPLAND_[BRONZE|SILVER|GOLD]_DB`
- **TEST**: `TEST_UPLAND_[BRONZE|SILVER|GOLD]_DB`
- **PROD**: `PROD_UPLAND_[BRONZE|SILVER|GOLD]_DB`

### Schema Generation

The `generate_schema_name` macro handles environment-specific schema names:

```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if default_schema in ['TEST','PROD'] -%}
        {{ custom_schema_name | trim }}
    {%- elif custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
```

**Behavior:**
- **DEV**: `MICHAEL_vault` (prefixed with developer)
- **PROD/TEST**: `vault` (no prefix)

---

## Performance Optimization

### Materialization Strategy

Choose the right materialization:

| Type | Use Case | Pros | Cons |
|------|----------|------|------|
| **view** | Small, fast transformations | Always fresh | Slow for complex queries |
| **table** | Most models (default) | Fast queries | Takes storage, rebuild time |
| **incremental** | Large fact tables | Efficient updates | Complex logic, hard to debug |
| **ephemeral** | Reusable CTEs | No storage | Can't query directly |

### Query Optimization

1. **Filter early** - Push WHERE clauses to CTEs
2. **Limit joins** - Only join what's needed
3. **Use indexes** - Though Snowflake handles this
4. **Avoid SELECT *** - Specify needed columns
5. **Use QUALIFY** - For window function filtering in Snowflake

### Model Timing

Monitor model execution times:
- Run `dbt ls --select state:modified+ --resource-type model`
- Check dbt Cloud run logs for slow models
- Optimize models taking >5 minutes

### Snowflake Optimization

Leverage Snowflake features:
- **Clustering keys** for large tables
- **Search optimization** for point queries
- **Result caching** (Snowflake automatic)
- **Warehouse sizing** for parallel builds

---

## Common Patterns

### Pattern: Hub Table with Multi-Source

```sql
{{
  config(
    materialized='table',
    schema='vault',
    database=env_var("DBT_SILVER_DB","DEV_UPLAND_SILVER_DB")
  )
}}

with source1 as (
    select
        id as entity_uid,
        entity_number,
        'SOURCE1' as record_source,
        {{ convert_utc_to_central_tz('created_date') }} as valid_from,
        change_event
    from {{ ref('stg_source1_entity') }}
),

source2 as (
    select
        id as entity_uid,
        entity_number,
        'SOURCE2' as record_source,
        {{ convert_utc_to_central_tz('created_date') }} as valid_from,
        change_event
    from {{ ref('stg_source2_entity') }}
),

combined as (
    {{ dbt_utils.union_relations(relations=[ref('source1'), ref('source2')]) }}
),

with_valid_to as (
    select
        *,
        {{ vault_valid_to('entity_uid', 'null') }} as valid_to
    from combined
)

select * from with_valid_to
```

### Pattern: Gold Layer Mart

```sql
{{
  config(
    materialized='table',
    schema='claim_reporting',
    database=env_var("DBT_GOLD_DB","DEV_UPLAND_GOLD_DB")
  )
}}

with claims as (
    select * from {{ ref('claim_hub') }}
    where valid_to is null  -- Current records only
),

payments as (
    select * from {{ ref('claim_payment_hub') }}
    where valid_to is null
),

final as (
    select
        c.claim_number,
        c.claimant_name,
        sum(p.payment_amount) as total_paid,
        count(p.payment_id) as payment_count,
        {{ pbi_timestamp() }} as refresh_timestamp
    from claims c
    left join payments p on c.claim_uid = p.claim_uid
    group by 1, 2
)

select * from final
```

---

## Troubleshooting

### Common Issues

**Issue: Model not building in correct order**
- **Solution**: Use `ref()` for all dependencies, not hardcoded names

**Issue: Schema name doesn't match environment**
- **Solution**: Check `generate_schema_name` macro and target schema

**Issue: Incremental model not updating**
- **Solution**: Run `dbt run --full-refresh --select model_name`

**Issue: Test failing on valid data**
- **Solution**: Review test logic, check for `valid_to is null` filter

**Issue: Macro not found**
- **Solution**: Run `dbt deps` to install packages

### Debugging Commands

```bash
# Compile without running
dbt compile --select model_name

# Run specific model
dbt run --select model_name

# Run model and downstream dependencies
dbt run --select model_name+

# Run model and upstream dependencies
dbt run --select +model_name

# Test specific model
dbt test --select model_name

# Generate documentation
dbt docs generate

# Serve documentation locally
dbt docs serve
```

---

## Checklist for New Models

- [ ] Model has explicit `config()` block
- [ ] Uses `ref()` or `source()` for all dependencies
- [ ] Follows Upland naming convention
- [ ] Includes schema and database configuration
- [ ] Uses appropriate Upland macros
- [ ] Has documentation in schema.yml
- [ ] Has appropriate tests defined
- [ ] SCD Type 2 logic correct (if vault model)
- [ ] Timezone conversions applied
- [ ] Follows layer-appropriate pattern (bronze/silver/gold)

---

## Additional Resources

- **Internal**: Upland dbt Cloud project at https://cloud.getdbt.com
- **dbt Docs**: https://docs.getdbt.com
- **Data Vault**: https://www.data-vault.co.uk
- **Snowflake dbt**: https://docs.getdbt.com/reference/warehouse-setups/snowflake-setup
