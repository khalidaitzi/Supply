{{
    config(
        severity='error',
        store_failures=true
    )
}}

select *
from {{ ref('fct_inventory_daily') }}

where available_qty
    <> on_hand_qty - allocated_qty
