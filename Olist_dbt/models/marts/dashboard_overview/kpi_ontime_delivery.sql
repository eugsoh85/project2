{{ config(
    materialized = 'view'
) }}

WITH delivery_data AS (
    SELECT
        order_id,
        DATE_TRUNC(DATE(order_purchase_timestamp), MONTH) AS order_month,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM {{ ref('stg_orders') }}
    WHERE order_status IN ('delivered', 'shipped')
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
),

categorized AS (
    SELECT
        order_month,
        COUNT(*) AS total_delivered,
        COUNTIF(DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date)) AS ontime_delivered
    FROM delivery_data
    GROUP BY order_month
)

SELECT
    order_month,
    total_delivered,
    ontime_delivered,
    SAFE_DIVIDE(ontime_delivered, total_delivered) AS ontime_delivery_pct
FROM categorized
ORDER BY order_month