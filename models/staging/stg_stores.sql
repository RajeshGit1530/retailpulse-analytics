with source as (

    select * from {{ source('retailpulse_landing', 'raw_stores') }}

),

renamed as (

    select
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

        -- calculate store age in years
        datediff('year',
            open_date,
            current_date())             as store_age_years,

        -- metadata
        created_at,
        updated_at,
        _loaded_at                      as dbt_loaded_at

    from source

)

select * from renamed