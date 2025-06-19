-- models/staging/stg_orders.sql

WITH raw AS (
    SELECT * FROM {{ source('raw', 'olist_orders_dataset') }}
),

deduped AS (
    SELECT * EXCEPT(row_num)
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY order_id
                ORDER BY order_purchase_timestamp DESC
            ) AS row_num
        FROM raw
    )
    WHERE row_num = 1
),

cleaned AS (
    SELECT
        order_id,
        customer_id,

        -- Standardize order status
        LOWER(TRIM(order_status)) AS order_status,

        -- Cleaned timestamp fields
        CASE
            WHEN TRIM(order_purchase_timestamp) = '' THEN NULL
            ELSE SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', REPLACE(order_purchase_timestamp, ' UTC', ''))
        END AS order_purchase_timestamp,

        CASE
            WHEN TRIM(order_approved_at) = '' THEN NULL
            ELSE SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', REPLACE(order_approved_at, ' UTC', ''))
        END AS order_approved_at,

        CASE
            WHEN TRIM(order_delivered_carrier_date) = '' THEN NULL
            ELSE SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', REPLACE(order_delivered_carrier_date, ' UTC', ''))
        END AS order_delivered_carrier_date,

        CASE
            WHEN TRIM(order_delivered_customer_date) = '' THEN NULL
            ELSE SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', REPLACE(order_delivered_customer_date, ' UTC', ''))
        END AS order_delivered_customer_date,

        CASE
            WHEN TRIM(order_estimated_delivery_date) = '' THEN NULL
            ELSE SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', REPLACE(order_estimated_delivery_date, ' UTC', ''))
        END AS order_estimated_delivery_date

    FROM deduped
)

SELECT * FROM cleaned