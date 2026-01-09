# Airflow/Astronomer Best Practices for Upland EDP

This document outlines best practices for Airflow DAG development at Upland Capital Group using Astronomer.

## Table of Contents
- [DAG Design Principles](#dag-design-principles)
- [Naming Conventions](#naming-conventions)
- [DAG Structure](#dag-structure)
- [Operators and Tasks](#operators-and-tasks)
- [Error Handling](#error-handling)
- [Connection Management](#connection-management)
- [Testing](#testing)
- [Performance](#performance)

---

## DAG Design Principles

### Decorator-Based Pattern (Airflow 3.0+)

**Always use @dag decorator**, not context manager:

```python
from airflow.decorators import dag
import pendulum

@dag(
    default_args=default_args,
    schedule="15 5 * * *",
    start_date=pendulum.from_format("2025-05-21", "YYYY-MM-DD").in_tz("America/Chicago"),
    catchup=False,
    tags=["source", "type", "frequency"]
)
def My_DAG_Name():
    # Task definitions
    pass

dag_obj = My_DAG_Name()
```

### Required Standards

**Every DAG MUST have:**
1. **Minimum 2 retries** on all tasks (enforced by tests)
2. **Tags** for categorization
3. **on_failure_callback** set to `notify_failure`
4. **America/Chicago timezone** for all schedules
5. **Owner links** with mailto and Cloud IDE links

---

## Naming Conventions

### DAG File Naming

Pattern: `[Source]_[Operation]_[Environment].py`

**Examples:**
- `FiveSigma_CSV_Ingestion_Pipeline_Prod.py`
- `NetAdj_CSV_Batch_Ingestion_Prod.py`
- `azure_ips_snowflake_rule_update.py`

### Task Naming

Use descriptive names in snake_case:
- `extract_zip_files`
- `test_snowflake_connection`
- `csv_ingestion_stored_proc`
- `validate_csv_sums`

---

## DAG Structure

### Complete DAG Template

```python
"""
DAG_Name

Description of what this DAG does.
"""

from airflow.decorators import dag
from airflow.operators.python import PythonOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator
import pendulum
from include.notify_failure import notify_failure

# Constants
CONTAINER_NAME = os.getenv("CONTAINER_NAME")
DBT_JOB_ID = 12345

default_args = {
    "owner": "Your Name",
    "retries": 2,  # Minimum 2 required
    "on_failure_callback": notify_failure,
}

@dag(
    default_args=default_args,
    schedule="15 5 * * *",  # Cron in America/Chicago
    start_date=pendulum.from_format("2025-05-21", "YYYY-MM-DD").in_tz("America/Chicago"),
    catchup=False,
    tags=["source", "csv-ingestion", "daily"],
    owner_links={
        "Your Name": "mailto:you@uplandcapgroup.com",
        "Cloud IDE": "https://cloud.astronomer.io/..."
    }
)
def DAG_Name():
    
    task1 = PythonOperator(
        task_id="task1",
        python_callable=function1,
        execution_timeout=pendulum.duration(minutes=30),
        retries=2,
    )
    
    task2 = SQLExecuteQueryOperator(
        task_id="task2",
        sql="CALL procedure();",
        conn_id="UCG_SVC_ASTRONOMER_KP",
        autocommit=True,
        execution_timeout=pendulum.duration(hours=1),
        retries=1,
    )
    
    # Dependencies
    task1 >> task2

dag_obj = DAG_Name()
```

---

## Operators and Tasks

### Primary Operators

#### 1. SQLExecuteQueryOperator (Snowflake)

```python
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

snowflake_task = SQLExecuteQueryOperator(
    task_id="execute_snowflake_proc",
    sql="CALL SCHEMA.PROCEDURE_NAME();",
    conn_id="UCG_SVC_ASTRONOMER_KP",
    autocommit=True,
    execution_timeout=pendulum.duration(hours=2),
    retries=1,
)
```

#### 2. PythonOperator

```python
from airflow.operators.python import PythonOperator

python_task = PythonOperator(
    task_id="process_files",
    python_callable=my_function,
    execution_timeout=pendulum.duration(minutes=20),
    retries=2,
)
```

#### 3. DbtCloudRunJobOperator

```python
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator

dbt_task = DbtCloudRunJobOperator(
    task_id="trigger_dbt_job",
    job_id=876364,
    dbt_cloud_conn_id="dbt_Conn",
    wait_for_termination=True,
    execution_timeout=pendulum.duration(hours=1),
    retries=1,
)
```

#### 4. FivetranOperator

```python
from fivetran_provider_async.operators import FivetranOperator

fivetran_task = FivetranOperator(
    task_id="trigger_fivetran",
    fivetran_conn_id="UCG_FIVETRAN_CONN",
    connector_id="connector_id_here",
    wait_for_completion=True,
    deferrable=False,
    retries=0,  # Typically no retries on Fivetran
)
```

### Task Dependencies

#### Simple Sequential
```python
task1 >> task2 >> task3
```

#### Parallel Tasks
```python
task1 >> [task2, task3] >> task4
```

#### Complex with chain()
```python
from airflow.models.baseoperator import chain

chain(
    task1,
    task2,
    [task3, task4],  # Parallel
    task5
)
```

---

## Error Handling

### Standard Failure Notification

```python
from include.notify_failure import notify_failure

default_args = {
    "on_failure_callback": notify_failure,
}
```

**notify_failure features:**
- Converts UTC to CST/CDT
- Formats error messages with context
- Links to Airflow logs
- Uses Apprise for notifications

### Custom Error Handling in Tasks

```python
def my_validation_function(**context):
    logger = logging.getLogger(__name__)
    
    try:
        # Validation logic
        result = perform_validation()
        
        if not result.is_valid:
            # Log to audit table
            log_validation_failure(result)
            
            # Send notification
            send_apprise_notification(
                apprise_conn_id="apprise_default",
                title="Validation Failed",
                body=f"Details: {result.message}",
                notify_type=NotifyType.WARNING,
            )(context)
            
            # Raise to block downstream
            raise Exception(f"Validation failed: {result.message}")
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise  # Re-raise to trigger failure callback
```

---

## Connection Management

### Connection Types

#### Snowflake (Key Pair Auth)
```yaml
- conn_id: UCG_SVC_ASTRONOMER_KP
  conn_type: snowflake
  conn_host: ${SNOWFLAKE_ACCOUNT}
  conn_login: ${SNOWFLAKE_USER}
  conn_extra:
    account: "${SNOWFLAKE_ACCOUNT}"
    warehouse: "${SNOWFLAKE_WAREHOUSE}"
    database: "${SNOWFLAKE_DATABASE}"
    schema: "${SNOWFLAKE_SCHEMA}"
    authenticator: "SNOWFLAKE_JWT"
    private_key: "[BASE64_ENCODED]"
```

#### dbt Cloud
```yaml
- conn_id: dbt_cloud_default
  conn_type: dbt_cloud
  conn_login: ${DBT_CLOUD_ACCOUNT_ID}
  conn_password: ${DBT_CLOUD_API_TOKEN}
```

#### Apprise (Notifications)
```yaml
- conn_id: apprise_default
  conn_type: apprise
  conn_extra:
    config: "sendgrid://..."
```

### Environment Variables

Store in `.env`:
```bash
SNOWFLAKE_ACCOUNT="UPLAND-EDP"
SNOWFLAKE_USER="UCG_SVC_ASTRONOMER"
DBT_CLOUD_ACCOUNT_ID=167119
AZURE_SAS_TOKEN="sp=racwdl..."
```

---

## Testing

### DAG Integrity Tests

Located in `/.astro/test_dag_integrity_default.py`:

**Enforced requirements:**
1. All DAGs must import without errors
2. All DAGs must have `tags` defined
3. All DAGs must have `retries >= 2`

**Run tests:**
```bash
pytest .astro/test_dag_integrity_default.py
```

### Local DAG Testing

```bash
# Parse DAGs
astro dev parse

# Test specific DAG
astro dev pytest -k "test_dag_name"

# Run DAG locally
astro dev start
```

---

## Performance

### Execution Timeouts

Set appropriate timeouts per task type:

| Task Type | Typical Timeout |
|-----------|-----------------|
| File extraction | 30 minutes |
| Snowflake connection test | 5 minutes |
| CSV import procedure | 2 hours |
| dbt Cloud job | 1 hour |
| Validation | 20 minutes |

### Parallel Execution

Run independent tasks in parallel:
```python
csv_ingestion_stored_proc >> [archive_files, cleanup_files] >> validate
```

### Resource Management

- Use appropriate Airflow worker resources
- Monitor DAG run duration
- Optimize slow Python operations
- Use Snowflake warehouse sizing appropriately

---

## SFTP Ingestion Pattern

### Pipeline Architecture

For SFTP-based ingestion (e.g., RIPro from Sapiens):

```
SFTP Server (paramiko)
    ↓
Azure Blob Storage (landing zone: files/)
    ↓
CSV Validation (bad line detection)
    ↓
Snowflake COPY INTO (schema evolution)
    ↓
Control File Validation (optional)
    ↓
Archive to date-based folders (archive/YYYY/MM/DD/)
```

### Multi-Factor SFTP Authentication

Some SFTP servers require **password + SSH key with passphrase**:

```python
import paramiko
import base64
import io

# Environment variables
SFTP_HOST = os.getenv("SFTP_HOST")
SFTP_PORT = int(os.getenv("SFTP_PORT", "22"))
SFTP_USERNAME = os.getenv("SFTP_USERNAME")
SFTP_PASSWORD = os.getenv("SFTP_PASSWORD")
SFTP_KEY_PASSPHRASE = os.getenv("SFTP_KEY_PASSPHRASE")
SFTP_PRIVATE_KEY_B64 = os.getenv("SFTP_PRIVATE_KEY_B64")  # Base64-encoded

def get_sftp_connection():
    """Establish SFTP connection with multi-factor auth."""
    transport = paramiko.Transport((SFTP_HOST, SFTP_PORT))

    # Load private key from base64-encoded env var
    pkey = None
    if SFTP_PRIVATE_KEY_B64:
        key_data = base64.b64decode(SFTP_PRIVATE_KEY_B64)
        key_file = io.StringIO(key_data.decode('utf-8'))

        # Try RSA, then Ed25519, then ECDSA
        try:
            pkey = paramiko.RSAKey.from_private_key(key_file, password=SFTP_KEY_PASSPHRASE)
        except paramiko.ssh_exception.SSHException:
            key_file.seek(0)
            pkey = paramiko.Ed25519Key.from_private_key(key_file, password=SFTP_KEY_PASSPHRASE)

    # Multi-factor: password + key
    transport.connect(username=SFTP_USERNAME, password=SFTP_PASSWORD, pkey=pkey)

    sftp = paramiko.SFTPClient.from_transport(transport)
    return sftp, transport
```

### Exponential Backoff Retry

For unreliable external connections:

```python
default_args = {
    "owner": "Your Name",
    "retries": 3,
    "retry_delay": pendulum.duration(seconds=60),
    "retry_exponential_backoff": True,
    "max_retry_delay": pendulum.duration(seconds=600),
    "on_failure_callback": notify_failure,
}
```

**Retry behavior:**
- Attempt 1: Wait 60s
- Attempt 2: Wait 120s
- Attempt 3: Wait 240s (capped at 600s)

---

## Bad Line Handling Strategies

### Strategy 1: Fail Fast (RIPro Pattern)

Reject entire file if any bad lines detected:

```python
def validate_csv_schema(**context):
    bad_lines_found = []

    def bad_line_handler(bad_line):
        bad_lines_found.append({
            'line_number': len(bad_lines_found) + 1,
            'content': str(bad_line)[:1000]
        })
        return None  # Skip line

    df = pd.read_csv(file, on_bad_lines=bad_line_handler, engine='python')

    if bad_lines_found:
        # Log to audit table
        log_bad_lines_to_snowflake(bad_lines_found)
        # Send notification
        notify_bad_lines(context, bad_lines_found)
        # Fail the task
        raise Exception(f"Found {len(bad_lines_found)} bad lines - file rejected")
```

**Use when:** Data integrity is critical, partial data is unacceptable.

### Strategy 2: Quarantine (FiveSigma Pattern)

Process valid rows, quarantine bad rows:

```python
def process_with_quarantine(**context):
    quarantine_rows = []

    for row in rows:
        if validate_row(row):
            valid_rows.append(row)
        else:
            quarantine_rows.append(row)

    # Process valid rows
    load_to_snowflake(valid_rows)

    # Archive quarantine for review
    if quarantine_rows:
        save_quarantine(quarantine_rows)
        notify_quarantine(context, len(quarantine_rows))
```

**Use when:** Partial data is acceptable, need to process what's valid.

---

## Control File Validation

Validate loaded data against control files (row counts, column sums):

```python
from include.ripro_control_file_validator import RIProControlFileValidator

def validate_control_files(**context):
    validator = RIProControlFileValidator(
        snowflake_conn_id="UCG_SVC_ASTRONOMER",
        environment="PROD",
        database="PROD_UPLAND_BRONZE_DB",
        schema="RIPRO"
    )

    # Parse control file (CSV with header + 1 data row)
    control_data = validator.parse_control_file(content)

    # Validate against staging table
    result = validator.validate_file(
        data_file_name="CASH_20260107",
        control_file_name="CASH_CNTL_20260107.txt",
        control_data=control_data,
        sum_columns=['AMOUNT', 'PREMIUM']  # Financial columns to validate
    )

    # Log result
    validator.log_validation_result(result)

    if result.validation_status == 'FAIL':
        notify_control_validation_failure(context, result)
```

**Validation tolerance:** < $0.01 for financial columns (handles floating-point precision).

---

## GitHub Actions Auto-Deploy

### Workflow Configuration

`.github/workflows/astronomer-deploy.yml`:

```yaml
name: Deploy to Astronomer

on:
  push:
    branches:
      - main
  workflow_dispatch:  # Manual trigger

env:
  ASTRO_API_TOKEN: ${{ secrets.ASTRO_API_TOKEN }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Deploy to Astronomer
        uses: astronomer/deploy-action@v0.3
        with:
          deployment-id: cmafuogmr0s2f01m04vv496du
          workspace: cm6qsb8s81l5d01l0t3brxfru
          force: true
```

### Manual Deployment

```bash
# Deploy DAGs only (faster, no image rebuild)
astro deploy <deployment-id> --dags

# Full deploy (includes requirements.txt changes)
astro deploy <deployment-id>
```

---

## Key Pipelines Reference

| DAG | Source | Pattern | Schedule |
|-----|--------|---------|----------|
| `FiveSigma_CSV_Ingestion_Pipeline_Prod` | Azure Blob | CSV → Snowflake | Daily |
| `NetAdj_CSV_Batch_Ingestion_Prod` | Azure Blob | CSV → Snowflake | Daily 6:15 AM CST |
| `RIPro_SFTP_Ingestions_Prod` | Sapiens SFTP | SFTP → Azure → Snowflake | Manual |
| `RIPro_SFTP_Ingestions_NonProd` | Sapiens SFTP | SFTP → Azure → Snowflake | Manual |

---

## Checklist for New DAGs

- [ ] Uses @dag decorator (not context manager)
- [ ] Has minimum retries=2 on all tasks
- [ ] Includes notify_failure callback
- [ ] Uses America/Chicago timezone
- [ ] Has descriptive tags
- [ ] Has owner links
- [ ] File named correctly: [Source]_[Operation]_[Env].py
- [ ] All connections use environment variables
- [ ] Execution timeouts set appropriately
- [ ] Dependencies clearly defined
- [ ] Passes DAG integrity tests
