{{ config(
    materialized = 'view'
) }}

SELECT
    DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
    t.product_category_name_english AS category,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_order_items') }} i
  ON o.order_id = i.order_id
JOIN {{ ref('stg_products') }} p
  ON i.product_id = p.product_id
JOIN {{ ref('stg_product_category_translation') }} t
  ON p.product_category_name = t.product_category_name
JOIN {{ ref('stg_reviews') }} r
  ON o.order_id = r.order_id
WHERE r.review_score IS NOT NULL
  AND o.order_status = 'delivered'
GROUP BY order_month, category
ORDER BY order_month, avg_review_score DESC