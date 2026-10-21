{{
    config(
        severity='error',
        store_failures=true
    )
}}

select *
from {{ ref('fct_shipments') }}

where delivery_date is not null
  and delivery_date < ship_date
