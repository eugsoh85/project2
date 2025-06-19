-- models/staging/stg_order_items.sql

SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    
    -- Standardize timestamp format
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_date,
    CAST(price AS FLOAT64) AS price,
    CAST(freight_value AS FLOAT64) AS freight_value,

FROM {{ source('raw', 'olist_order_items_dataset') }}