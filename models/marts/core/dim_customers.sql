with customer_summary as (

    select * from {{ ref('int_customer_order_summary') }}

),

final as (

    select
        -- primary key
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }}
                                                as customer_sk,
        customer_id,

        -- customer details
        full_name,
        email,
        city,
        country,
        customer_segment,
        is_active,
        registration_date,

        -- order metrics
        total_orders,
        completed_orders,
        cancelled_orders,
        returned_orders,
        total_revenue,
        avg_order_value,
        min_order_value,
        max_order_value,
        first_order_date,
        last_order_date,
        customer_lifetime_days,
        favourite_payment_method,
        customer_value_tier,

        -- derived metrics
        case
            when total_orders > 0
            then round(
                cancelled_orders / total_orders * 100
            , 2)
            else 0
        end                                     as cancellation_rate,

        case
            when total_orders > 0
            then round(
                returned_orders / total_orders * 100
            , 2)
            else 0
        end                                     as return_rate,

        -- customer status
        case
            when last_order_date >= dateadd('day', -90, current_date())
                then 'ACTIVE'
            when last_order_date >= dateadd('day', -180, current_date())
                then 'AT_RISK'
            when last_order_date >= dateadd('day', -365, current_date())
                then 'LAPSED'
            when last_order_date is null
                then 'NEVER_ORDERED'
            else 'CHURNED'
        end                                     as customer_status

    from customer_summary

)

select * from final