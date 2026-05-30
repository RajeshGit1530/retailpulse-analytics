with source as (

    select * from {{ source('retailpulse_landing', 'raw_orders') }}

),

renamed as (

    select
        -- primary key
        order_id,

        -- foreign keys
        customer_id,
        store_id,
        promotion_id,

        -- order dates
        order_date,
        required_date,
        shipped_date,
        delivered_date,

        -- calculate processing days
        datediff('day',
            order_date,
            coalesce(shipped_date,
                     current_timestamp())) as order_processing_days,

        -- calculate delivery days
        datediff('day',
            shipped_date,
            coalesce(delivered_date,
                     current_timestamp())) as delivery_days,

        -- order status
        order_status,
        payment_method,
        payment_status,

        -- status flags
        case
            when order_status = 'DELIVERED'
            then true else false
        end                                 as is_completed,

        case
            when order_status = 'CANCELLED'
            then true else false
        end                                 as is_cancelled,

        case
            when order_status = 'RETURNED'
            then true else false
        end                                 as is_returned,

        -- amounts
        subtotal_amount,
        discount_amount,
        shipping_amount,
        tax_amount,
        total_amount,
        currency,

        -- shipping
        shipping_address,
        shipping_city,
        shipping_country,

        notes,

        -- metadata
        created_at,
        updated_at,
        _loaded_at                          as dbt_loaded_at

    from source

)

select * from renamed