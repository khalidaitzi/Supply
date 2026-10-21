{{
    config(
        severity='error',
        store_failures=true
    )
}}

select *
from {{ ref('fct_sales') }}

where quantity <= 0
   or unit_price < 0
   or discount_pct < 0
   or discount_pct > 1
   or gross_sales_amount < 0
   or discount_amount < 0
   or net_sales_amount < 0
   or total_standard_cost < 0
