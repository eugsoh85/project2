-- models/staging/stg_customers.sql

WITH raw AS (
    SELECT * FROM {{ source('raw', 'olist_customers_dataset') }}
),

deduped AS (
    SELECT * EXCEPT(row_num)
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_unique_id) AS row_num
        FROM raw
    )
    WHERE row_num = 1
),

cleaned AS (
    SELECT
        customer_id,
        customer_unique_id,
        
        -- Preserve ZIP prefix as string
        CAST(customer_zip_code_prefix AS STRING) AS customer_zip_code_prefix,
        
        -- Format city and state for consistency + readability
        INITCAP(TRIM(customer_city)) AS customer_city,
        UPPER(TRIM(customer_state)) AS customer_state

    FROM deduped
)

SELECT * FROM cleaned
