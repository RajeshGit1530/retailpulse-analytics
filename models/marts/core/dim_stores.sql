with stores as (

    select * from {{ ref('stg_stores') }}

),

final as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['store_id']) }}
                                                as store_sk,
        -- primary key
        store_id,

        -- store details
        store_name,
        store_type,
        region,
        country,
        city,
        address,
        manager_name,
        open_date,
        is_active,
        store_age_years,

        -- store classification
        case
            when store_type = 'ONLINE'      then 'DIGITAL'
            when store_type = 'MOBILE_APP'  then 'DIGITAL'
            when store_type = 'PHYSICAL'    then 'PHYSICAL'
            else                                 'OTHER'
        end                                 as store_channel,

        -- store status
        case
            when is_active = true
            then 'ACTIVE'
            else 'INACTIVE'
        end                                 as store_status,

        -- metadata
        created_at,
        updated_at,
        dbt_loaded_at

    from stores

)

select * from final