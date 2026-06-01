with orders as (

    select * from {{ ref('fct_orders') }}

),

dim_date as (

    select * from {{ ref('dim_date') }}

),

dim_stores as (

    select * from {{ ref('dim_stores') }}

),

final as (

    select
        -- date dimensions
        d.full_date,
        d.year,
        d.month_number,
        d.month_name,
        d.quarter,
        d.is_weekend,

        -- store dimensions
        s.store_name,
        s.store_type,
        s.store_channel,
        s.region,
        s.city,

        -- sales metrics
        count(o.order_id)               as total_orders,
        count(case when o.is_completed
            then 1 end)                 as completed_orders,
        count(case when o.is_cancelled
            then 1 end)                 as cancelled_orders,
        count(case when o.is_returned
            then 1 end)                 as returned_orders,

        -- revenue metrics
        sum(o.total_amount)             as total_revenue,
        avg(o.total_amount)             as avg_order_value,
        sum(o.discount_amount)          as total_discounts,
        sum(o.shipping_amount)          as total_shipping,
        sum(o.tax_amount)               as total_tax,
        sum(o.total_gross_profit)       as total_gross_profit,

        -- item metrics
        sum(o.total_items_count)        as total_items_sold,
        sum(o.total_quantity)           as total_quantity_sold

    from orders o
    left join dim_date d
        on o.order_date_key = d.date_key
    left join dim_stores s
        on o.store_sk = s.store_sk
    where o.is_cancelled = false
    group by
        d.full_date,
        d.year,
        d.month_number,
        d.month_name,
        d.quarter,
        d.is_weekend,
        s.store_name,
        s.store_type,
        s.store_channel,
        s.region,
        s.city

)

select * from final