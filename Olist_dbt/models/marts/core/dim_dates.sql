WITH dates AS (
    SELECT DISTINCT DATE(order_purchase_timestamp) AS date
    FROM {{ ref('stg_orders') }}
),
enriched AS (
    SELECT
        date,
        EXTRACT(YEAR FROM date) AS year,
        EXTRACT(MONTH FROM date) AS month,
        EXTRACT(DAY FROM date) AS day,
        EXTRACT(DAYOFWEEK FROM date) AS day_of_week,
        FORMAT_DATE('%A', date) AS day_name,
        EXTRACT(WEEK FROM date) AS week_of_year,
        IF(EXTRACT(DAYOFWEEK FROM date) IN (1, 7), TRUE, FALSE) AS is_weekend
    FROM dates
)
SELECT * FROM enriched