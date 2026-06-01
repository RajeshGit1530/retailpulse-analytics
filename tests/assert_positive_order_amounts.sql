-- tests/assert_positive_order_amounts.sql
-- Orders should never have negative total amounts

select
    order_id,
    total_amount
from {{ ref('fct_orders') }}
where total_amount < 0