{{ config(
    materialized = 'view'
) }}

WITH review_data AS (
    SELECT
        DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
        r.review_score,
        o.order_id,
        DATE(o.order_purchase_timestamp) AS purchase_date,
        DATE(o.order_delivered_customer_date) AS delivered_date
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_reviews') }} r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND r.review_score IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_purchase_timestamp IS NOT NULL
)

SELECT
    order_month,
    COUNT(*) AS total_reviews,
    COUNTIF(review_score >= 4) AS satisfied_reviews,
    ROUND(SAFE_DIVIDE(COUNTIF(review_score >= 4), COUNT(*)), 4) AS satisfaction_rate,
    ROUND(AVG(DATE_DIFF(delivered_date, purchase_date, DAY)), 2) AS avg_fulfilment_days
FROM review_data
GROUP BY order_month
ORDER BY order_month
