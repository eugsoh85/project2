{{ config(
    materialized = 'view'
) }}

WITH payment_data AS (
    SELECT
        DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
        p.payment_type,
        p.payment_value
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_payments') }} p
        ON o.order_id = p.order_id
    WHERE o.order_status IN ('delivered', 'shipped')
)

SELECT
    order_month,
    payment_type,
    SUM(payment_value) AS total_payment
FROM payment_data
GROUP BY order_month, payment_type
ORDER BY order_month