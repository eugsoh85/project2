SELECT
    seller_id,
    INITCAP(seller_city) AS seller_city,
    seller_state
FROM {{ ref('stg_sellers') }}