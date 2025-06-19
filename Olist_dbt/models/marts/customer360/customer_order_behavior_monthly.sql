{{ config(
    materialized = 'view'
) }}

WITH orders_with_flags AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
        o.order_status,
        o.order_id,
        i.price,
        CASE WHEN COUNT(DISTINCT o.order_id) OVER (PARTITION BY c.customer_unique_id) > 1 THEN 1 ELSE 0 END AS is_repeat_customer
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_customers') }} c
        ON o.customer_id = c.customer_id
    JOIN {{ ref('stg_order_items') }} i
        ON o.order_id = i.order_id
    WHERE o.order_status IS NOT NULL
)

SELECT
    order_month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN is_repeat_customer = 1 THEN order_id END) AS repeat_orders,
    COUNT(DISTINCT CASE WHEN order_status = 'delivered' THEN order_id END) AS completed_orders,
    SUM(CASE WHEN is_repeat_customer = 1 THEN price ELSE 0 END) AS repeat_customer_spend,
    SUM(CASE WHEN is_repeat_customer = 0 THEN price ELSE 0 END) AS new_customer_spend
FROM orders_with_flags
GROUP BY order_month
ORDER BY order_month