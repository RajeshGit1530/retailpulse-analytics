with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('int_orders_with_items') }}

),

customer_orders as (

    select
        customer_id,

        -- order counts
        count(order_id)                     as total_orders,
        count(case when is_completed
            then 1 end)                     as completed_orders,
        count(case when is_cancelled
            then 1 end)                     as cancelled_orders,
        count(case when is_returned
            then 1 end)                     as returned_orders,

        -- revenue metrics
        sum(total_amount)                   as total_revenue,
        avg(total_amount)                   as avg_order_value,
        min(total_amount)                   as min_order_value,
        max(total_amount)                   as max_order_value,

        -- date metrics
        min(order_date)                     as first_order_date,
        max(order_date)                     as last_order_date,
        datediff('day',
            min(order_date),
            max(order_date))                as customer_lifetime_days,

        -- payment preference
        mode(payment_method)                as favourite_payment_method

    from orders
    where is_cancelled = false
    group by customer_id

),

final as (

    select
        -- customer details
        c.customer_id,
        c.full_name,
        c.email,
        c.customer_segment,
        c.city,
        c.country,
        c.is_active,
        c.registration_date,

        -- order summary
        coalesce(co.total_orders, 0)            as total_orders,
        coalesce(co.completed_orders, 0)        as completed_orders,
        coalesce(co.cancelled_orders, 0)        as cancelled_orders,
        coalesce(co.returned_orders, 0)         as returned_orders,
        coalesce(co.total_revenue, 0)           as total_revenue,
        coalesce(co.avg_order_value, 0)         as avg_order_value,
        co.min_order_value,
        co.max_order_value,
        co.first_order_date,
        co.last_order_date,
        coalesce(co.customer_lifetime_days, 0)  as customer_lifetime_days,
        co.favourite_payment_method,

        -- customer value tier
        case
            when coalesce(co.total_revenue, 0) > 200000
                then 'VIP'
            when coalesce(co.total_revenue, 0) > 50000
                then 'HIGH'
            when coalesce(co.total_revenue, 0) > 10000
                then 'MEDIUM'
            else 'LOW'
        end                                     as customer_value_tier

    from customers c
    left join customer_orders co
        on c.customer_id = co.customer_id

)

select * from final