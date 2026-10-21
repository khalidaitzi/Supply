{{
    config(
        severity='error',
        store_failures=true
    )
}}

select *
from {{ ref('fct_purchase_orders') }}

where expected_date < order_date

   or (
       received_date is not null
       and received_date < order_date
   )
