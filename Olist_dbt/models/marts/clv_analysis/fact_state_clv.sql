{{ config(materialized = 'table') }}

-- Step 1: Load fact orders and customer dimension
with fact_orders as (
    select *
    from {{ ref('fact_customer_orders') }}
),

customers as (
    select *
    from {{ ref('dim_customers') }}
),

-- Step 2: Join orders with customers
orders_with_customers as (
    select
        f.order_id,
        c.customer_id,
        c.customer_unique_id,
        c.customer_state,
        f.order_purchase_timestamp,
        f.total_payment
    from fact_orders f
    left join customers c using(customer_id)
),

-- Step 3: Assign one state per customer based on first order
first_order_state as (
    select
        customer_unique_id,
        customer_state as assigned_state
    from (
        select
            customer_unique_id,
            customer_state,
            order_purchase_timestamp,
            row_number() over (
                partition by customer_unique_id
                order by order_purchase_timestamp asc
            ) as rn
        from orders_with_customers
    )
    where rn = 1
),

-- Step 4: Compute CLV per customer
clv_per_customer as (
    select
        owc.customer_unique_id,
        fos.assigned_state as state,
        sum(owc.total_payment) as customer_lifetime_value
    from orders_with_customers owc
    join first_order_state fos using(customer_unique_id)
    group by owc.customer_unique_id, fos.assigned_state
),

-- Step 5: Aggregate per state
clv_aggregated_state as (
    select
        state,
        count(*) as total_customers,
        sum(customer_lifetime_value) as total_clv,
        avg(customer_lifetime_value) as avg_clv,
        max(customer_lifetime_value) as max_clv,
        min(customer_lifetime_value) as min_clv
    from clv_per_customer
    group by state
)

select *
from clv_aggregated_state
order by avg_clv desc, total_customers desc






