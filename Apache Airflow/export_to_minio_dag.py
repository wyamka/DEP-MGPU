"""
Export Data to MinIO DAG
========================

This DAG exports transformed data from PostgreSQL to MinIO object storage.

Author: Data Engineering Team
Date: 2024
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from airflow.utils.dates import days_ago
from airflow.hooks.base import BaseHook
import logging
import os
import pandas as pd
import psycopg2
from minio import Minio
import io
import json

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
    'export_to_minio',
    default_args=default_args,
    description='Export transformed data from PostgreSQL to MinIO',
    schedule_interval='@daily',
    max_active_runs=1,
    tags=['export', 'minio', 'postgresql'],
)


def export_audit_data_to_minio(**context):
    """Export audit data from PostgreSQL to MinIO"""
    try:
        # Get PostgreSQL connection from Airflow
        pg_conn = BaseHook.get_connection('external_postgres')
        
        # PostgreSQL connection
        pg_conn_params = {
            'host': pg_conn.host,
            'port': pg_conn.port,
            'database': pg_conn.schema,
            'user': pg_conn.login,
            'password': pg_conn.password
        }
        
        # Connect to PostgreSQL
        conn = psycopg2.connect(**pg_conn_params)
        
        # Query data from marts_04 schema
        query = """
        SELECT 
            audit_id,
            audit_date,
            auditor_name,
            department,
            audit_type,
            process_name,
            compliance_score,
            non_conformities_count,
            critical_issues,
            minor_issues,
            recommendations_count,
            audit_status,
            next_audit_date,
            audit_duration_hours,
            certification_level
        FROM marts_04.stg_quality_audits
        ORDER BY audit_date DESC
        """
        
        # Export to DataFrame
        df = pd.read_sql(query, conn)
        conn.close()
        
        logging.info(f"Exported {len(df)} records from PostgreSQL")
        
        # MinIO connection
        minio_client = Minio(
            'minio:9000',
            access_key='quality-mgmt-key',
            secret_key='quality-mgmt-secret123',
            secure=False
        )
        
        # Ensure bucket exists
        bucket_name = 'quality-management-data'
        if not minio_client.bucket_exists(bucket_name):
            minio_client.make_bucket(bucket_name)
            logging.info(f"Created bucket: {bucket_name}")
        
        # Export to CSV
        csv_buffer = io.StringIO()
        df.to_csv(csv_buffer, index=False)
        csv_data = csv_buffer.getvalue()
        
        # Upload to MinIO
        file_name = f"audit_data_{context['ds']}.csv"
        minio_client.put_object(
            bucket_name,
            file_name,
            io.BytesIO(csv_data.encode('utf-8')),
            length=len(csv_data.encode('utf-8')),
            content_type='text/csv'
        )
        
        logging.info(f"Successfully uploaded {file_name} to MinIO")
        
        # Export summary statistics as JSON
        summary = {
            'export_date': context['ds'],
            'total_records': len(df),
            'departments': df['department'].nunique(),
            'auditors': df['auditor_name'].nunique(),
            'avg_compliance_score': round(df['compliance_score'].mean(), 2),
            'file_name': file_name
        }
        
        summary_json = json.dumps(summary, indent=2)
        summary_file_name = f"audit_summary_{context['ds']}.json"
        
        minio_client.put_object(
            bucket_name,
            summary_file_name,
            io.BytesIO(summary_json.encode('utf-8')),
            length=len(summary_json.encode('utf-8')),
            content_type='application/json'
        )
        
        logging.info(f"Successfully uploaded {summary_file_name} to MinIO")
        
        return summary
        
    except Exception as e:
        logging.error(f"Failed to export data: {str(e)}")
        raise

def export_compliance_summary_to_minio(**context):
    """Export compliance summary by department"""
    try:
        # Get PostgreSQL connection from Airflow
        pg_conn = BaseHook.get_connection('external_postgres')
        
        # PostgreSQL connection
        pg_conn_params = {
            'host': pg_conn.host,
            'port': pg_conn.port,
            'database': pg_conn.schema,
            'user': pg_conn.login,
            'password': pg_conn.password
        }
        
        conn = psycopg2.connect(**pg_conn_params)
        
        # Department compliance summary
        query = """
        SELECT 
            department,
            COUNT(*) as total_audits,
            ROUND(AVG(compliance_score), 2) as avg_compliance_score,
            MIN(compliance_score) as min_compliance_score,
            MAX(compliance_score) as max_compliance_score,
            SUM(critical_issues) as total_critical_issues,
            SUM(minor_issues) as total_minor_issues
        FROM marts_04.stg_quality_audits
        GROUP BY department
        ORDER BY avg_compliance_score DESC
        """
        
        df = pd.read_sql(query, conn)
        conn.close()
        
        # MinIO connection
        minio_client = Minio(
            'minio:9000',
            access_key='quality-mgmt-key',
            secret_key='quality-mgmt-secret123',
            secure=False
        )
        
        bucket_name = 'quality-management-data'
        
        # Export to CSV
        csv_buffer = io.StringIO()
        df.to_csv(csv_buffer, index=False)
        csv_data = csv_buffer.getvalue()
        
        # Upload to MinIO
        file_name = f"compliance_summary_{context['ds']}.csv"
        minio_client.put_object(
            bucket_name,
            file_name,
            io.BytesIO(csv_data.encode('utf-8')),
            length=len(csv_data.encode('utf-8')),
            content_type='text/csv'
        )
        
        logging.info(f"Successfully uploaded compliance summary: {file_name}")
        
        return f"Exported compliance summary for {len(df)} departments"
        
    except Exception as e:
        logging.error(f"Failed to export compliance summary: {str(e)}")
        raise

# Task 1: Start notification
start_task = DummyOperator(
    task_id='start_export',
    dag=dag,
)

# Task 2: Export audit data
export_audit_data = PythonOperator(
    task_id='export_audit_data',
    python_callable=export_audit_data_to_minio,
    dag=dag,
)

# Task 3: Export compliance summary
export_compliance_summary = PythonOperator(
    task_id='export_compliance_summary',
    python_callable=export_compliance_summary_to_minio,
    dag=dag,
)

# Task 4: End notification
end_task = DummyOperator(
    task_id='end_export',
    dag=dag,
)

# Define task dependencies
start_task >> export_audit_data >> export_compliance_summary >> end_task
