{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge'
    )
}}

with orders as (

    select * from {{ ref('int_orders_with_items') }}

    {% if is_incremental() %}
        where updated_at > (
            select max(updated_at)
            from {{ this }}
        )
    {% endif %}

),

dim_customers as (

    select * from {{ ref('dim_customers') }}

),

dim_stores as (

    select * from {{ ref('dim_stores') }}

),

dim_promotions as (

    select * from {{ ref('dim_promotions') }}

),

dim_date as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['order_id']) }}
                                                as order_sk,

        -- natural key
        o.order_id,

        -- foreign keys
        c.customer_sk,
        s.store_sk,
        p.promotion_sk,
        d.date_key                              as order_date_key,

        -- order details
        o.order_date,
        o.order_status,
        o.payment_method,
        o.payment_status,

        -- flags
        o.is_completed,
        o.is_cancelled,
        o.is_returned,
        o.has_returns,

        -- amounts
        o.subtotal_amount,
        o.discount_amount,
        o.shipping_amount,
        o.tax_amount,
        o.total_amount,

        -- item metrics
        o.total_items_count,
        o.total_quantity,
        o.total_gross_profit,
        o.returned_items_count,

        -- processing metrics
        o.order_processing_days,
        o.delivery_days,

        -- metadata
        o.created_at,
        o.updated_at,
        o.dbt_loaded_at

    from orders o
    left join dim_customers c
        on o.customer_id = c.customer_id
    left join dim_stores s
        on o.store_id = s.store_id
    left join dim_promotions p
        on o.promotion_id = p.promotion_id
    left join dim_date d
        on cast(o.order_date as date) = d.date_key

)

select * from final