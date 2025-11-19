#!/bin/sh

export DBT_VENV_PATH="${AIRFLOW_HOME}/dbt_venv"

python3 -m venv "${DBT_VENV_PATH}"

# Install dbt-redshift 1.7.7 (compatible with astronomer-cosmos)
# Version 1.7.7 supports --output-keys argument required by Cosmos
${DBT_VENV_PATH}/bin/pip install dbt-redshift==1.7.7
