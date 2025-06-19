import subprocess
import os
from dagster import asset


@asset
def run_dbt_staging():
    """
    Run dbt models in the staging folder.
    """
    dbt_project_path = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "../../../Olist_dbt"))

    result = subprocess.run(
        ["dbt", "run", "--select", "path:models/staging/"],
        cwd=dbt_project_path,  # path to your dbt project from dagster_orchestration
        capture_output=True,
        text=True
    )

    print("STDOUT:\n", result.stdout)
    print("STDERR:\n", result.stderr)

    if result.returncode != 0:
        raise Exception("dbt staging models failed to run")


@asset
def run_dbt_tests(run_dbt_staging):
    """
    Run dbt tests on staging models (defined in schema.yml).
    """
    dbt_project_path = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "../../../Olist_dbt"))

    result = subprocess.run(
        ["dbt", "test", "--select", "path:models/staging/"],
        cwd=dbt_project_path,
        capture_output=True,
        text=True
    )

    print("STDOUT:\n", result.stdout)
    print("STDERR:\n", result.stderr)

    if result.returncode != 0:
        raise Exception("dbt tests failed — data quality issue detected.")


@asset
def run_dbt_marts(run_dbt_tests):  # test is an input dependency
    """
    Run dbt models in the marts folder after staging completes.
    """
    dbt_project_path = os.path.abspath(os.path.join(
        os.path.dirname(__file__), "../../../Olist_dbt"))

    result = subprocess.run(
        ["dbt", "run", "--select", "path:models/marts/core/"],
        cwd=dbt_project_path,  # path to your dbt project from dagster_orchestration
        capture_output=True,
        text=True
    )

    print("STDOUT:\n", result.stdout)
    print("STDERR:\n", result.stderr)

    if result.returncode != 0:
        raise Exception("dbt mart models failed to run")

