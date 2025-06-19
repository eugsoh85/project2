{{ config(
    materialized = 'view'
) }}

WITH delivery_data AS (
    SELECT
        DATE_TRUNC(DATE(order_purchase_timestamp), MONTH) AS order_month,
        CASE
            WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date)
                THEN 'on_time'
            ELSE 'late'
        END AS delivery_status
    FROM {{ ref('stg_orders') }}
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)

SELECT
    order_month,
    delivery_status,
    COUNT(*) AS order_count
FROM delivery_data
GROUP BY order_month, delivery_status
ORDER BY order_month