-- tests/assert_valid_margin.sql
-- Product margins should be between 0 and 100%

select
    product_id,
    profit_margin_pct
from {{ ref('stg_products') }}
where profit_margin_pct < 0
   or profit_margin_pct > 100