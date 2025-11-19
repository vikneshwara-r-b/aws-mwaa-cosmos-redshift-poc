# FROM astrocrpublic.azurecr.io/runtime:3.1-2
FROM quay.io/astronomer/astro-runtime:9.1.0-python-3.9-base

ENV AIRFLOW__WEBSERVER__SHOW_TRIGGER_FORM_IF_NO_PARAMS=True

# install dbt into a virtual environment
RUN python -m venv dbt_venv && . dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-redshift==1.4.0 dbt-colibri>=0.7.0 && deactivate

# Ensure cosmos is available (requirements.txt should handle this, but explicit install for safety)
RUN pip install --no-cache-dir astronomer-cosmos==1.4.3
