{{ config(materialized = 'table') }}

-- Pre-aggregate order items
with order_items_agg as (
    select
        order_id,
        sum(price + freight_value) as gross_revenue
    from {{ ref('stg_order_items') }}
    group by order_id
),

-- Pre-aggregate order payments
order_payments_agg as (
    select
        order_id,
        sum(payment_value) as total_payment
    from {{ ref('stg_payments') }}
    group by order_id
),

-- Load orders table
orders as (
    select
        order_id,
        customer_id,
        order_purchase_timestamp
    from {{ ref('stg_orders') }}
),

-- Join pre-aggregated values
customer_orders as (
    select
        o.customer_id,
        o.order_id,
        o.order_purchase_timestamp,
        oi.gross_revenue,
        p.total_payment
    from orders o
    left join order_items_agg oi using(order_id)
    left join order_payments_agg p using(order_id)
    where p.total_payment is not null
)

select * from customer_orders



