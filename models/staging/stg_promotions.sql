with source as (

    select * from {{ source('retailpulse_landing', 'raw_promotions') }}

),

renamed as (

    select
        -- primary key
        promotion_id,

        -- promotion details
        promotion_name,
        promotion_type,
        discount_value,
        min_order_value,
        promo_code,

        -- dates
        start_date,
        end_date,

        -- calculate promotion duration
        datediff('day',
            start_date,
            end_date)                       as promotion_duration_days,

        -- usage
        max_uses,
        current_uses,
        round(
            current_uses
            / nullif(max_uses, 0) * 100
        , 2)                                as utilization_pct,

        applicable_category,
        is_active,

        -- metadata
        created_at,
        updated_at,
        _loaded_at                          as dbt_loaded_at

    from source

)

select * from renamed