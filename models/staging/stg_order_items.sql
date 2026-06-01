with source as (

    select * from {{ source('retailpulse_landing', 'raw_order_items') }}

),

renamed as (

    select
        -- primary key
        order_item_id,

        -- foreign keys
        order_id,
        product_id,

        -- item details
        quantity,
        unit_price,
        cost_price,
        discount_amount,
        line_total,

        -- calculated metrics
        quantity * unit_price               as gross_amount,

        round(
            (unit_price - cost_price)
            * quantity
        , 2)                                as gross_profit,

        round(
            (unit_price - cost_price)
            / nullif(unit_price, 0) * 100
        , 2)                                as gross_margin_pct,

        -- validity flag
        case
            when quantity > 0
            then true
            else false
        end                                 as is_valid_item,

        -- return details
        is_returned,
        return_date,
        return_reason,

        -- metadata
        created_at,
        updated_at,
        _loaded_at                          as dbt_loaded_at

    from source

)

select * from renamed