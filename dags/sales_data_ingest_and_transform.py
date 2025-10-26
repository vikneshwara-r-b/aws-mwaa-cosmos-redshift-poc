from airflow.decorators import dag
from airflow.operators.empty import EmptyOperator

from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, RenderConfig, ExecutionConfig
from cosmos.profiles import RedshiftUserPasswordProfileMapping
from cosmos.constants import TestBehavior

from pendulum import datetime
import os

CONNECTION_ID = "redshift_default"
DB_NAME = "sales_dw"
SCHEMA_NAME = "public"

ROOT_PATH = '/usr/local/airflow/dags/dbt'
DBT_PROJECT_PATH = f"{ROOT_PATH}/sales_dw"

airflow_home = os.environ.get("AIRFLOW_HOME", "/usr/local/airflow")

profile_config = ProfileConfig(
    profile_name="sales_dw",
    target_name="dev",
    profile_mapping=RedshiftUserPasswordProfileMapping(
        conn_id=CONNECTION_ID,
        profile_args={"schema": SCHEMA_NAME},
    )
)

execution_config = ExecutionConfig(
    dbt_executable_path=f"{airflow_home}/dbt_venv/bin/dbt",
)


@dag(
    start_date=datetime(2023, 10, 14),
    schedule=None,
    catchup=False
)
def sales_data_ingest_and_transform():

    start_process = EmptyOperator(task_id='start_process')

    transform_data = DbtTaskGroup(
        group_id="transform_data",
        project_config=ProjectConfig(DBT_PROJECT_PATH),
        profile_config=profile_config,
        execution_config=execution_config,
        render_config=RenderConfig(
            test_behavior=TestBehavior.NONE,
        ),
        default_args={"retries": 2},
    )

    end_process = EmptyOperator(task_id='end_process')

    start_process >> transform_data >> end_process


sales_data_ingest_and_transform()