select
    i.snapshot_date,
    i.warehouse_key,
    w.warehouse_id,
    w.warehouse_name,
    w.country,
    w.region,

    i.product_key,
    p.product_id,
    p.product_name,
    p.product_category,
    p.product_subcategory,

    i.on_hand_qty,
    i.allocated_qty,
    i.available_qty,
    i.reorder_point,

    i.inventory_status,
    i.is_stockout,
    i.is_below_reorder_point,
    i.stock_coverage_index,

    i.available_qty
        * p.standard_cost as available_inventory_value,

    i.on_hand_qty
        * p.standard_cost as on_hand_inventory_value

from {{ ref('fct_inventory_daily') }} i

inner join {{ ref('dim_warehouses') }} w
    on i.warehouse_key = w.warehouse_key

inner join {{ ref('dim_products') }} p
    on i.product_key = p.product_key
