with sales as (

    select
        order_date as metric_date,
        warehouse_key,

        count(distinct order_id) as order_count,
        sum(quantity) as units_sold,
        sum(gross_sales_amount) as gross_sales_amount,
        sum(discount_amount) as discount_amount,
        sum(net_sales_amount) as net_sales_amount,
        sum(total_standard_cost) as total_standard_cost,
        sum(gross_margin_amount) as gross_margin_amount

    from {{ ref('fct_sales') }}

    where order_status <> 'CANCELLED'

    group by
        order_date,
        warehouse_key

),

shipments as (

    select
        ship_date as metric_date,
        warehouse_key,

        count(*) as shipment_count,

        avg(
            case
                when is_on_time_delivery = true then 1
                when is_on_time_delivery = false then 0
            end
        ) as on_time_delivery_rate,

        avg(transit_days) as average_transit_days,
        sum(freight_cost) as freight_cost

    from {{ ref('fct_shipments') }}

    group by
        ship_date,
        warehouse_key

),

final as (

    select
        coalesce(
            s.metric_date,
            sh.metric_date
        ) as metric_date,

        coalesce(
            s.warehouse_key,
            sh.warehouse_key
        ) as warehouse_key,

        coalesce(s.order_count, 0)
            as order_count,

        coalesce(s.units_sold, 0)
            as units_sold,

        coalesce(s.gross_sales_amount, 0)
            as gross_sales_amount,

        coalesce(s.discount_amount, 0)
            as discount_amount,

        coalesce(s.net_sales_amount, 0)
            as net_sales_amount,

        coalesce(s.total_standard_cost, 0)
            as total_standard_cost,

        coalesce(s.gross_margin_amount, 0)
            as gross_margin_amount,

        {{ safe_divide(
            's.gross_margin_amount',
            's.net_sales_amount'
        ) }} as gross_margin_rate,

        coalesce(sh.shipment_count, 0)
            as shipment_count,

        sh.on_time_delivery_rate,
        sh.average_transit_days,

        coalesce(sh.freight_cost, 0)
            as freight_cost

    from sales s

    full outer join shipments sh
        on s.metric_date = sh.metric_date
        and s.warehouse_key = sh.warehouse_key

)

select *
from final
