-- models/staging/stg_product_category_translation.sql

WITH cleaned AS (
    SELECT
        LOWER(TRIM(product_category_name)) AS product_category_name,
        INITCAP(REPLACE(TRIM(product_category_name_english), '_', ' ')) AS product_category_name_english
    FROM {{ source('raw', 'product_category_name_translation') }}
    WHERE product_category_name IS NOT NULL
)

SELECT DISTINCT * FROM cleaned