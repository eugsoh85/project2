SELECT
    product_category_name,
    product_category_name_english
FROM {{ ref('stg_product_category_translation') }}