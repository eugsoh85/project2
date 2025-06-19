{{ config(
    materialized = 'view'
) }}

WITH sales_data AS (
    SELECT
        o.order_id,
        DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
        t.product_category_name_english AS category,
        i.price
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_order_items') }} i
        ON o.order_id = i.order_id
    JOIN {{ ref('stg_products') }} p
        ON i.product_id = p.product_id
    JOIN {{ ref('stg_product_category_translation') }} t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status IN ('delivered', 'shipped')
)

SELECT
    order_month,
    category,
    SUM(price) AS total_sales
FROM sales_data
GROUP BY order_month, category
ORDER BY order_month, total_sales DESC