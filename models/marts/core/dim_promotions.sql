with promotions as (

    select * from {{ ref('stg_promotions') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['promotion_id']) }}
                                                as promotion_sk,
        -- primary key
        promotion_id,

        -- promotion details
        promotion_name,
        promotion_type,
        discount_value,
        min_order_value,
        promo_code,
        applicable_category,

        -- dates
        start_date,
        end_date,
        promotion_duration_days,

        -- usage metrics
        max_uses,
        current_uses,
        utilization_pct,
        is_active,

        -- promotion classification
        case
            when promotion_type = 'PERCENTAGE'
                then 'DISCOUNT'
            when promotion_type = 'FIXED_AMOUNT'
                then 'DISCOUNT'
            when promotion_type = 'BOGO'
                then 'OFFER'
            when promotion_type = 'FREE_SHIPPING'
                then 'SHIPPING'
            else 'OTHER'
        end                                     as promotion_category,

        -- promotion effectiveness
        case
            when utilization_pct >= 80  then 'HIGH'
            when utilization_pct >= 50  then 'MEDIUM'
            when utilization_pct >= 20  then 'LOW'
            else                             'VERY_LOW'
        end                                     as utilization_tier,

        -- is promotion currently running
        case
            when current_date() between start_date and end_date
                and is_active = true
            then true
            else false
        end                                     as is_currently_active,

        -- metadata
        created_at,
        updated_at,
        dbt_loaded_at

    from promotions

)

select * from final