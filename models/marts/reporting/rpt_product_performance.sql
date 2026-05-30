with order_items as (

    select * from {{ ref('fct_order_items') }}

),

products as (

    select * from {{ ref('dim_products') }}

),

product_metrics as (

    select
        product_id,
        count(order_item_id)            as total_line_items,
        sum(quantity)                   as total_units_sold,
        sum(line_total)                 as total_revenue,
        sum(gross_profit)               as total_gross_profit,
        avg(gross_margin_pct)           as avg_gross_margin_pct,
        sum(discount_amount)            as total_discounts,
        count(case when is_returned
            then 1 end)                 as total_returns,
        round(
            count(case when is_returned
                then 1 end)
            / nullif(count(order_item_id), 0) * 100
        , 2)                            as return_rate

    from order_items
    where is_valid_item = true
    group by product_id

),

final as (

    select
        -- product details
        p.product_id,
        p.product_name,
        p.product_sku,
        p.category,
        p.subcategory,
        p.brand,
        p.department,

        -- pricing
        p.cost_price,
        p.selling_price,
        p.profit_margin_pct,
        p.margin_tier,
        p.is_active,
        p.is_discontinued,

        -- sales metrics
        coalesce(pm.total_line_items, 0)    as total_line_items,
        coalesce(pm.total_units_sold, 0)    as total_units_sold,
        coalesce(pm.total_revenue, 0)       as total_revenue,
        coalesce(pm.total_gross_profit, 0)  as total_gross_profit,
        coalesce(pm.avg_gross_margin_pct,0) as avg_gross_margin_pct,
        coalesce(pm.total_discounts, 0)     as total_discounts,
        coalesce(pm.total_returns, 0)       as total_returns,
        coalesce(pm.return_rate, 0)         as return_rate,

        -- performance classification
        case
            when coalesce(pm.total_revenue, 0) = 0
                then 'NO_SALES'
            when coalesce(pm.total_revenue, 0) > 100000
                then 'TOP_PERFORMER'
            when coalesce(pm.total_revenue, 0) > 50000
                then 'GOOD_PERFORMER'
            when coalesce(pm.total_revenue, 0) > 10000
                then 'AVERAGE_PERFORMER'
            else 'LOW_PERFORMER'
        end                                 as performance_tier,

        -- rank by revenue within category
        rank() over (
            partition by p.category
            order by coalesce(pm.total_revenue, 0) desc
        )                                   as revenue_rank_in_category

    from products p
    left join product_metrics pm
        on p.product_id = pm.product_id

)

select * from final