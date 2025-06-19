{{ config(
    materialized = 'view'
) }}

WITH reviews AS (
    SELECT
        r.review_score,
        DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month
    FROM {{ ref('stg_reviews') }} r
    JOIN {{ ref('stg_orders') }} o USING (order_id)
    WHERE r.review_score IS NOT NULL
)

SELECT
    order_month,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    COUNT(*) AS total_reviews
FROM reviews
GROUP BY order_month
ORDER BY order_month