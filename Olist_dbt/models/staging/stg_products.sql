-- models/staging/stg_products.sql

WITH raw AS (
    SELECT * FROM {{ source('raw', 'olist_products_dataset') }}
),

deduped AS (
    SELECT * EXCEPT (row_num)
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS row_num
        FROM raw
    )
    WHERE row_num = 1
),

cleaned AS (
    SELECT
        product_id,
        
        -- Fill missing category with 'unknown' to pass not_null test
        COALESCE(LOWER(TRIM(product_category_name)), 'unknown') AS product_category_name,
        
        CAST(product_name_lenght AS INT64) AS product_name_length,
        CAST(product_description_lenght AS INT64) AS product_description_length,
        CAST(product_photos_qty AS INT64) AS product_photos_qty,
        
        -- Use SAFE_CAST to prevent "Bad int64 value" errors
        COALESCE(NULLIF(SAFE_CAST(product_weight_g AS INT64), 0), -1) AS product_weight_g,
        COALESCE(NULLIF(SAFE_CAST(product_length_cm AS INT64), 0), -1) AS product_length_cm,
        COALESCE(NULLIF(SAFE_CAST(product_height_cm AS INT64), 0), -1) AS product_height_cm,
        COALESCE(NULLIF(SAFE_CAST(product_width_cm AS INT64), 0), -1) AS product_width_cm

    FROM deduped
)

SELECT * FROM cleaned
