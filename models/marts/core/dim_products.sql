with products as (

    select * from {{ ref('stg_products') }}

),

category_mapping as (

    select * from {{ ref('product_category_mapping') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['product_id']) }}
                                                as product_sk,
        -- primary key
        p.product_id,

        -- product details
        p.product_name,
        p.product_sku,
        p.category,
        p.subcategory,
        p.brand,
        p.supplier,

        -- pricing
        p.cost_price,
        p.selling_price,
        p.gross_profit,
        p.profit_margin_pct,

        -- category enrichment from seed
        c.department,
        c.is_seasonal,
        c.profit_margin_pct         as category_margin_pct,

        -- product attributes
        p.weight_kg,
        p.launch_date,
        p.discontinue_date,
        p.is_active,
        p.is_discontinued,
        p.description,

        -- product age in days
        datediff('day',
            p.launch_date,
            current_date())         as product_age_days,

        -- performance tier
        case
            when p.profit_margin_pct >= 40  then 'HIGH_MARGIN'
            when p.profit_margin_pct >= 25  then 'MEDIUM_MARGIN'
            else                                 'LOW_MARGIN'
        end                         as margin_tier,

        -- metadata
        p.created_at,
        p.updated_at,
        p.dbt_loaded_at

    from products p
    left join category_mapping c
        on p.category = c.category

)

select * from final