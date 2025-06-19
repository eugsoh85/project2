SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- Delivery metrics
    DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY) AS actual_delivery_days,
    DATE_DIFF(o.order_estimated_delivery_date, o.order_purchase_timestamp, DAY) AS estimated_delivery_days,
    SAFE_DIVIDE(
        DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY),
        ABS(DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY))
    ) <= 0 AS is_late,
    o.order_status = 'delivered' AS is_completed,

    -- Order item detail (1 row per item)
    i.order_item_id,
    i.product_id,
    i.seller_id,
    i.price,
    i.freight_value,

    -- Payment detail (assumes 1 payment method per order)
    p.payment_type,
    p.payment_value,

    -- Review detail (assumes 1 review per order)
    r.review_score

FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('stg_order_items') }} i USING (order_id)
LEFT JOIN {{ ref('stg_payments') }} p USING (order_id)
LEFT JOIN {{ ref('stg_reviews') }} r USING (order_id)