from dagster import Definitions, ScheduleDefinition, define_asset_job
from .assets import run_dbt_staging, run_dbt_tests, run_dbt_marts

daily_job = define_asset_job(name="daily_etl_job")

daily_schedule = ScheduleDefinition(
    job=daily_job,
    cron_schedule="0 9 * * *",  # 9 AM daily
    execution_timezone="Asia/Singapore",
)

defs = Definitions(
    assets=[run_dbt_staging, run_dbt_tests, run_dbt_marts],
    schedules=[daily_schedule],
)