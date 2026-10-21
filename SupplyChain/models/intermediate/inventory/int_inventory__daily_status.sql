with inventory as (

    select *
    from {{ ref('inventory_snapshots') }}

),

final as (

    select
        snapshot_date,
        warehouse_id,
        product_id,

        on_hand_qty,
        allocated_qty,
        available_qty,
        reorder_point,

        case
            when available_qty <= 0 then 'STOCKOUT'
            when available_qty <= reorder_point then 'REORDER'
            when available_qty <= reorder_point * 1.5 then 'LOW'
            else 'HEALTHY'
        end as inventory_status,

        available_qty <= 0
            as is_stockout,

        available_qty <= reorder_point
            as is_below_reorder_point,

        {{ safe_divide(
            'available_qty',
            'reorder_point'
        ) }} as stock_coverage_index,

        loaded_at as record_loaded_at,
        airflow_run_id

    from inventory

)

select *
from final
