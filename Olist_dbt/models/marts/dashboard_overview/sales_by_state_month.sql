{{ config(
    materialized = 'view'
) }}

WITH sales_data AS (
    SELECT
        o.order_id,
        DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
        c.customer_state,
        p.payment_value
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_customers') }} c
        ON o.customer_id = c.customer_id
    JOIN {{ ref('stg_payments') }} p
        ON o.order_id = p.order_id
    WHERE o.order_status IN ('delivered', 'shipped')
)

SELECT
    order_month,
    customer_state,
    SUM(payment_value) AS total_revenue
FROM sales_data
GROUP BY order_month, customer_state
ORDER BY order_month, customer_state