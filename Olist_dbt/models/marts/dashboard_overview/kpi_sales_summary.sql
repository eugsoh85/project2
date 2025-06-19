{{ config(
    materialized = 'view'
) }}

WITH revenue_data AS (
    SELECT
        o.order_id,
        DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
        SUM(p.payment_value) AS total_revenue
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_payments') }} p
        ON o.order_id = p.order_id
    WHERE o.order_status IN ('delivered', 'shipped')
      AND p.payment_value IS NOT NULL 
    GROUP BY o.order_id, order_month
),

orders_summary AS (
    SELECT
        order_month,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_revenue) AS total_revenue
    FROM revenue_data
    GROUP BY order_month
)

SELECT
    order_month,
    total_orders,
    total_revenue,
    ROUND(total_revenue / total_orders, 2) AS avg_order_value
FROM orders_summary
ORDER BY order_month