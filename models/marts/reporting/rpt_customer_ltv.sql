with customers as (

    select * from {{ ref('dim_customers') }}

),

final as (

    select
        -- customer identity
        customer_id,
        full_name,
        email,
        city,
        country,

        -- segmentation
        customer_segment,
        customer_value_tier,
        customer_status,

        -- order metrics
        total_orders,
        completed_orders,
        cancelled_orders,
        returned_orders,

        -- revenue metrics
        total_revenue,
        avg_order_value,
        min_order_value,
        max_order_value,

        -- lifetime metrics
        first_order_date,
        last_order_date,
        customer_lifetime_days,
        favourite_payment_method,

        -- derived metrics
        cancellation_rate,
        return_rate,

        -- LTV classification
        case
            when total_revenue > 200000
                and total_orders >= 5
                then 'CHAMPION'
            when total_revenue > 100000
                and total_orders >= 3
                then 'LOYAL'
            when first_order_date >=
                dateadd('day', -90, current_date())
                then 'NEW_CUSTOMER'
            when last_order_date <=
                dateadd('day', -180, current_date())
                and total_orders >= 2
                then 'AT_RISK'
            when total_orders = 0
                then 'PROSPECT'
            else 'REGULAR'
        end                             as ltv_segment,

        -- revenue bands
        case
            when total_revenue = 0
                then 'NO_REVENUE'
            when total_revenue < 10000
                then '0-10K'
            when total_revenue < 50000
                then '10K-50K'
            when total_revenue < 100000
                then '50K-100K'
            when total_revenue < 200000
                then '100K-200K'
            else '200K+'
        end                             as revenue_band

    from customers

)

select * from final