"""
Quality Management DBT DAG for External PostgreSQL
==================================================

This DAG runs dbt transformations for quality management audit data
using external PostgreSQL database.

Author: Data Engineering Team
Date: 2024
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from airflow.utils.dates import days_ago
from airflow.hooks.base import BaseHook
import logging
import os

# Default arguments for the DAG
default_args = {
    'owner': 'data-engineering-team',
    'depends_on_past': False,
    'start_date': days_ago(1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'catchup': False,
}

# DAG configuration
dag = DAG(
    'quality_management_dbt_external',
    default_args=default_args,
    description='Quality Management System DBT Pipeline (External PostgreSQL)',
    schedule_interval='@daily',
    max_active_runs=1,
    tags=['dbt', 'quality-management', 'external-postgres'],
)

# Path to dbt project
DBT_PROJECT_DIR = '/opt/airflow/dbt-project'

def setup_external_postgres_connection(**context):
    """Setup environment variables from Airflow Connection"""
    try:
        # Get connection from Airflow
        conn = BaseHook.get_connection('external_postgres')
        
        # Set environment variables for dbt
        os.environ['AIRFLOW_CONN_EXTERNAL_POSTGRES_HOST'] = conn.host
        os.environ['AIRFLOW_CONN_EXTERNAL_POSTGRES_USER'] = conn.login
        os.environ['AIRFLOW_CONN_EXTERNAL_POSTGRES_PASSWORD'] = conn.password
        os.environ['AIRFLOW_CONN_EXTERNAL_POSTGRES_PORT'] = str(conn.port)
        os.environ['AIRFLOW_CONN_EXTERNAL_POSTGRES_DBNAME'] = conn.schema
        
        logging.info(f"Connection setup successful: {conn.host}:{conn.port}/{conn.schema}")
        return True
    except Exception as e:
        logging.error(f"Failed to setup connection: {str(e)}")
        raise

def log_dbt_start(**context):
    """Log the start of dbt execution"""
    logging.info(f"Starting dbt execution for run_id: {context['run_id']}")
    logging.info(f"Execution date: {context['ds']}")

def log_dbt_completion(**context):
    """Log the completion of dbt execution"""
    logging.info(f"Completed dbt execution for run_id: {context['run_id']}")
    logging.info(f"Execution date: {context['ds']}")

# Task 1: Start notification
start_task = DummyOperator(
    task_id='start_pipeline',
    dag=dag,
)

# Task 2: Setup connection
setup_connection = PythonOperator(
    task_id='setup_external_postgres_connection',
    python_callable=setup_external_postgres_connection,
    dag=dag,
)

# Task 3: Log start
log_start = PythonOperator(
    task_id='log_dbt_start',
    python_callable=log_dbt_start,
    dag=dag,
)

# Task 4: dbt run - Execute models
dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir .",
    dag=dag,
)

# Task 5: dbt test - Run tests
dbt_test = BashOperator(
    task_id='dbt_test',
    bash_command=f"cd {DBT_PROJECT_DIR} && dbt test --profiles-dir .",
    dag=dag,
)

# Task 6: Log completion
log_completion = PythonOperator(
    task_id='log_dbt_completion',
    python_callable=log_dbt_completion,
    dag=dag,
)

# Task 7: End notification
end_task = DummyOperator(
    task_id='end_pipeline',
    dag=dag,
)

# Define task dependencies
start_task >> setup_connection >> log_start >> dbt_run >> dbt_test >> log_completion >> end_task
