SELECT
    customer_id,
    customer_unique_id,
    INITCAP(customer_city) AS customer_city,
    customer_state,
    customer_zip_code_prefix
FROM {{ ref('stg_customers') }}