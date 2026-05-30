with source as (

    select * from {{ source('retailpulse_landing', 'raw_customers') }}

),

renamed as (

    select
        -- primary key
        customer_id,

        -- customer details
        first_name,
        last_name,
        first_name || ' ' || last_name     as full_name,
        lower(email)                        as email,
        phone,
        date_of_birth,
        gender,

        -- calculate age
        datediff('year',
            date_of_birth,
            current_date())                 as customer_age,

        -- address
        address_line1,
        city,
        state,
        country,
        postal_code,

        -- classification
        customer_segment,
        registration_date,
        is_active,

        -- metadata
        created_at,
        updated_at,
        _loaded_at                          as dbt_loaded_at

    from source

)

select * from renamed