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
