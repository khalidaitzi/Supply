with purchase_orders as (

    select *
    from {{ ref('purchase_orders') }}

),

purchase_order_lines as (

    select *
    from {{ ref('purchase_order_lines') }}

),

final as (

    select
        pol.po_line_id,
        pol.purchase_order_id,
        pol.product_id,

        po.supplier_id,
        po.warehouse_id,
        po.order_date,
        po.expected_date,
        po.received_date,
        po.purchase_order_status,

        pol.ordered_qty,
        pol.received_qty,
        pol.unit_cost,

        pol.ordered_qty
            * pol.unit_cost as ordered_amount,

        pol.received_qty
            * pol.unit_cost as received_amount,

        greatest(
            pol.ordered_qty - pol.received_qty,
            0
        ) as missing_qty,

        {{ safe_divide(
            'pol.received_qty',
            'pol.ordered_qty'
        ) }} as fill_rate,

        case
            when po.received_date is not null
            then datediff(
                day,
                po.order_date,
                po.received_date
            )
        end as actual_lead_time_days,

        case
            when po.received_date is null then null
            when po.received_date <= po.expected_date then true
            else false
        end as is_supplier_on_time,

        case
            when po.received_date is null then null
            else greatest(
                datediff(
                    day,
                    po.expected_date,
                    po.received_date
                ),
                0
            )
        end as supplier_delay_days,

        greatest(
            pol.loaded_at,
            po.loaded_at
        ) as record_loaded_at,

        pol.airflow_run_id

    from purchase_order_lines pol

    inner join purchase_orders po
        on pol.purchase_order_id = po.purchase_order_id

)

select *
from final
