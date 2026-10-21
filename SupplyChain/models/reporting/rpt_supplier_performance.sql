select
    date_trunc(
        'month',
        po.order_date
    )::date as performance_month,

    po.supplier_key,
    s.supplier_id,
    s.supplier_name,
    s.country,
    s.risk_tier,

    count(distinct po.purchase_order_id)
        as purchase_order_count,

    count(po.po_line_id)
        as purchase_order_line_count,

    sum(po.ordered_qty)
        as ordered_qty,

    sum(po.received_qty)
        as received_qty,

    sum(po.missing_qty)
        as missing_qty,

    {{ safe_divide(
        'sum(po.received_qty)',
        'sum(po.ordered_qty)'
    ) }} as weighted_fill_rate,

    avg(po.actual_lead_time_days)
        as average_lead_time_days,

    avg(
        case
            when po.is_supplier_on_time = true then 1
            when po.is_supplier_on_time = false then 0
        end
    ) as supplier_on_time_rate,

    avg(po.supplier_delay_days)
        as average_delay_days,

    sum(po.ordered_amount)
        as ordered_amount,

    sum(po.received_amount)
        as received_amount

from {{ ref('fct_purchase_orders') }} po

inner join {{ ref('dim_suppliers') }} s
    on po.supplier_key = s.supplier_key

group by
    performance_month,
    po.supplier_key,
    s.supplier_id,
    s.supplier_name,
    s.country,
    s.risk_tier
