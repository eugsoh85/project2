{{ config(
    materialized = 'view'
) }}

WITH first_orders AS (
    SELECT
        c.customer_unique_id,
        MIN(DATE_TRUNC(DATE(o.order_purchase_timestamp), QUARTER)) AS first_order_quarter
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_customers') }} c
        ON o.customer_id = c.customer_id
    WHERE o.order_status IN ('delivered', 'shipped')
    GROUP BY c.customer_unique_id
)

SELECT
    first_order_quarter,
    COUNT(*) AS new_customers
FROM first_orders
GROUP BY first_order_quarter
ORDER BY first_order_quarter