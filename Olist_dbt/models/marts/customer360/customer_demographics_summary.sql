{{ config(
    materialized = 'view'
) }}

WITH all_orders AS (
    SELECT
        c.customer_unique_id,
        c.customer_city,
        o.order_id,
        o.order_purchase_timestamp,
        i.price
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_customers') }} c
        ON o.customer_id = c.customer_id
    JOIN {{ ref('stg_order_items') }} i
        ON o.order_id = i.order_id
    WHERE o.order_status IN ('delivered', 'shipped')
),

first_orders AS (
    SELECT
        customer_unique_id,
        MIN(DATE(order_purchase_timestamp)) AS first_order_date
    FROM all_orders
    GROUP BY customer_unique_id
),

summary AS (
    SELECT
        customer_unique_id,
        customer_city,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(price) AS lifetime_spend
    FROM all_orders
    GROUP BY customer_unique_id, customer_city
)

SELECT
    s.customer_unique_id,
    s.customer_city,
    f.first_order_date,
    s.total_orders,
    s.lifetime_spend,
    CASE WHEN s.total_orders > 1 THEN 1 ELSE 0 END AS is_repeat_customer
FROM summary s
JOIN first_orders f
  ON s.customer_unique_id = f.customer_unique_id