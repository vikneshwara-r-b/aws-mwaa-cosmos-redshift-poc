from airflow.decorators import dag
from airflow.operators.empty import EmptyOperator

from cosmos.operators import DbtDocsOperator
from cosmos import ProfileConfig
from cosmos.profiles import RedshiftUserPasswordProfileMapping

from pendulum import datetime
import os
import subprocess
import shutil

CONNECTION_ID = "redshift_default"
DB_NAME = "sales_dw"
SCHEMA_NAME = "public"

ROOT_PATH = '/usr/local/airflow/dags/dbt'
DBT_PROJECT_PATH = f"{ROOT_PATH}/sales_dw"

airflow_home = os.environ.get("AIRFLOW_HOME", "/usr/local/airflow")

# Profile config - same as main DAG
profile_config = ProfileConfig(
    profile_name="sales_dw",
    target_name="dev",
    profile_mapping=RedshiftUserPasswordProfileMapping(
        conn_id=CONNECTION_ID,
        profile_args={"schema": SCHEMA_NAME},
    )
)

def generate_colibri_docs(project_dir: str):
    """
    Callback function to generate dbt-colibri documentation after dbt docs are created
    
    Args:
        project_dir: Path to the dbt project directory
    """
    print(f"Starting dbt-colibri documentation generation for project: {project_dir}")
    
    try:
        # Change to project directory
        os.chdir(project_dir)
        
        # Run colibri generate with the dbt virtual environment
        colibri_cmd = [f"{airflow_home}/dbt_venv/bin/colibri", "generate", "--debug"]
        
        print(f"Running command: {' '.join(colibri_cmd)}")
        
        result = subprocess.run(
            colibri_cmd,
            capture_output=True,
            text=True,
            check=True
        )
        
        print("dbt-colibri generation completed successfully!")
        print(f"STDOUT: {result.stdout}")
        
        # List generated files
        target_dir = os.path.join(project_dir, "target")
        dist_dir = os.path.join(project_dir, "dist")
        
        if os.path.exists(target_dir):
            print(f"DBT docs files in {target_dir}:")
            for file in os.listdir(target_dir):
                if file.endswith(('.html', '.json')):
                    print(f"  - {file}")
        
        if os.path.exists(dist_dir):
            print(f"dbt-colibri files in {dist_dir}:")
            for file in os.listdir(dist_dir):
                if file.endswith('.html'):
                    print(f"  - {file}")
        
        # Copy files to persistent location accessible on host machine
        persistent_docs_dir = "/usr/local/airflow/dags/generated_docs"
        os.makedirs(persistent_docs_dir, exist_ok=True)
        
        print(f"Copying documentation files to persistent location: {persistent_docs_dir}")
        
        # Copy dbt-colibri files
        if os.path.exists(dist_dir):
            colibri_html = os.path.join(dist_dir, "index.html")
            colibri_manifest = os.path.join(dist_dir, "colibri-manifest.json")
            
            if os.path.exists(colibri_html):
                shutil.copy2(colibri_html, os.path.join(persistent_docs_dir, "colibri-docs.html"))
                print("  ✅ Copied colibri-docs.html")
            
            if os.path.exists(colibri_manifest):
                shutil.copy2(colibri_manifest, os.path.join(persistent_docs_dir, "colibri-manifest.json"))
                print("  ✅ Copied colibri-manifest.json")
        
        # Copy standard dbt docs
        if os.path.exists(target_dir):
            dbt_html = os.path.join(target_dir, "index.html")
            dbt_manifest = os.path.join(target_dir, "manifest.json")
            dbt_catalog = os.path.join(target_dir, "catalog.json")
            
            if os.path.exists(dbt_html):
                shutil.copy2(dbt_html, os.path.join(persistent_docs_dir, "dbt-docs.html"))
                print("  ✅ Copied dbt-docs.html")
            
            if os.path.exists(dbt_manifest):
                shutil.copy2(dbt_manifest, os.path.join(persistent_docs_dir, "manifest.json"))
                print("  ✅ Copied manifest.json")
                
            if os.path.exists(dbt_catalog):
                shutil.copy2(dbt_catalog, os.path.join(persistent_docs_dir, "catalog.json"))
                print("  ✅ Copied catalog.json")
        
        print(f"📁 All documentation files available at: {persistent_docs_dir}")
        print("🌐 Files will be accessible on host machine at: dags/generated_docs/")
        
    except subprocess.CalledProcessError as e:
        print(f"Error running colibri generate: {e}")
        print(f"STDOUT: {e.stdout}")
        print(f"STDERR: {e.stderr}")
        raise
    except Exception as e:
        print(f"Unexpected error during colibri generation: {e}")
        raise


@dag(
    dag_id="dbt_documentation_generation",
    start_date=datetime(2023, 10, 14),
    schedule=None,
    catchup=False,
    description="Generate DBT documentation and enhanced dbt-colibri documentation using Cosmos operators",
    tags=["dbt", "documentation", "colibri", "cosmos"]
)
def dbt_documentation_generation():

    start_docs = EmptyOperator(task_id='start_documentation_process')

    # Generate DBT docs with colibri callback
    generate_docs = DbtDocsOperator(
        task_id="generate_dbt_and_colibri_docs",
        project_dir=DBT_PROJECT_PATH,
        profile_config=profile_config,
        dbt_executable_path=f"{airflow_home}/dbt_venv/bin/dbt",
        callback=generate_colibri_docs,
    )

    end_docs = EmptyOperator(task_id='end_documentation_process')

    start_docs >> generate_docs >> end_docs


dbt_documentation_generation()
