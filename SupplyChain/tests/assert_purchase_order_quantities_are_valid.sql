{{
    config(
        severity='error',
        store_failures=true
    )
}}

select *
from {{ ref('fct_purchase_orders') }}

where ordered_qty <= 0
   or received_qty < 0
   or received_qty > ordered_qty
   or fill_rate < 0
   or fill_rate > 1
