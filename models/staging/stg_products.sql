with source as (

    select * from {{ source('retailpulse_landing', 'raw_products') }}

),

renamed as (

    select
        -- primary key
        product_id,

        -- product details
        product_name,
        product_sku,
        category,
        subcategory,
        brand,
        supplier,

        -- pricing
        cost_price,
        selling_price,
        selling_price - cost_price          as gross_profit,
        round(
            (selling_price - cost_price)
            / nullif(selling_price, 0) * 100
        , 2)                                as profit_margin_pct,

        -- product attributes
        weight_kg,
        launch_date,
        discontinue_date,
        is_active,

        -- derived flags
        case
            when discontinue_date is not null
            then true
            else false
        end                                 as is_discontinued,

        description,

        -- metadata
        created_at,
        updated_at,
        _loaded_at                          as dbt_loaded_at

    from source

)

select * from renamed