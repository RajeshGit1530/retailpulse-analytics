with orders as (

    select * from {{ ref('stg_orders') }}

),

order_items as (

    select * from {{ ref('stg_order_items') }}

),

order_items_summary as (

    select
        order_id,
        count(order_item_id)        as total_items_count,
        sum(quantity)               as total_quantity,
        sum(line_total)             as total_line_amount,
        sum(gross_profit)           as total_gross_profit,
        sum(discount_amount)        as total_item_discounts,
        max(case when is_returned
            then 1 else 0 end)      as has_returns,
        count(case when is_returned
            then 1 end)             as returned_items_count

    from order_items
    where is_valid_item = true
    group by order_id

),

final as (

    select
        -- order details
        o.order_id,
        o.customer_id,
        o.store_id,
        o.promotion_id,
        o.order_date,
        o.order_status,
        o.payment_method,
        o.payment_status,
        o.is_completed,
        o.is_cancelled,
        o.is_returned,

        -- amounts from order
        o.subtotal_amount,
        o.discount_amount,
        o.shipping_amount,
        o.tax_amount,
        o.total_amount,

        -- enriched from items
        oi.total_items_count,
        oi.total_quantity,
        oi.total_gross_profit,
        oi.has_returns,
        oi.returned_items_count,

        -- metadata
        o.created_at,
        o.updated_at,
        o.dbt_loaded_at,
        o.order_processing_days,
        o.delivery_days

    from orders o
    left join order_items_summary oi
        on o.order_id = oi.order_id

)

select * from final