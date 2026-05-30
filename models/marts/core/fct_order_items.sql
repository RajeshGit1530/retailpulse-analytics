{{
    config(
        materialized='incremental',
        unique_key='order_item_id',
        incremental_strategy='merge'
    )
}}

with order_items as (
    select * from {{ref('stg_order_items')}}
    {%if is_incremental()%}
        where updated_at>(select max(updated_at) from {{this}})
    {%endif%}

),

orders as (

    select * from {{ ref('fct_orders') }}

),

dim_products as (

    select * from {{ ref('dim_products') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['order_item_id']) }}
                                                as order_item_sk,

        -- natural key
        oi.order_item_id,

        -- foreign keys
        o.order_sk,
        o.customer_sk,
        o.store_sk,
        o.order_date_key,
        p.product_sk,

        -- order reference
        oi.order_id,
        oi.product_id,

        -- item details
        oi.quantity,
        oi.unit_price,
        oi.cost_price,
        oi.discount_amount,
        oi.line_total,
        oi.gross_amount,
        oi.gross_profit,
        oi.gross_margin_pct,
        oi.is_valid_item,

        -- product enrichment
        p.product_name,
        p.category,
        p.subcategory,
        p.brand,
        p.margin_tier,

        -- return details
        oi.is_returned,
        oi.return_date,
        oi.return_reason,

        -- metadata
        oi.created_at,
        oi.updated_at,
        oi.dbt_loaded_at

    from order_items oi
    left join orders o
        on oi.order_id = o.order_id
    left join dim_products p
        on oi.product_id = p.product_id

)

select * from final