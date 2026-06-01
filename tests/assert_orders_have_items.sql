-- tests/assert_orders_have_items.sql
-- Every completed order should have at least one order item

select
    o.order_id
from {{ ref('fct_orders') }} o
left join {{ ref('fct_order_items') }} oi
    on o.order_id = oi.order_id
where o.is_completed = true
and oi.order_item_id is null