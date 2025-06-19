-- models/staging/stg_sellers.sql

WITH raw as (

    select
        seller_id,
        cast(seller_zip_code_prefix as string) as seller_zip_code_prefix,
        trim(lower(seller_city)) as seller_city,
        upper(trim(seller_state)) as seller_state

    from {{ source('raw', 'olist_sellers_dataset') }}

),

deduplicated as (

    select *
    from (
        select *,
               row_number() over (partition by seller_id order by seller_zip_code_prefix) as row_num
        from raw
    )
    where row_num = 1

),

cleaned as (

    select
        seller_id,
        seller_zip_code_prefix,
        initcap(seller_city) as seller_city,  -- e.g., 'sao paulo' -> 'Sao Paulo'
        seller_state
    from deduplicated

)

select * from cleaned