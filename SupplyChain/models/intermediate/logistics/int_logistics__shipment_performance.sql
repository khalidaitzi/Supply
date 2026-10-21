with shipments as (

    select *
    from {{ ref('shipments') }}

),

orders as (

    select *
    from {{ ref('orders') }}

),

final as (

    select
        s.shipment_id,
        s.order_id,
        s.carrier_id,

        o.customer_id,
        o.warehouse_id,

        o.order_date,
        o.promised_date,

        s.ship_date,
        s.delivery_date,
        s.shipment_status,
        s.tracking_number,
        s.freight_cost,

        datediff(
            day,
            o.order_date,
            s.ship_date
        ) as order_to_ship_days,

        case
            when s.delivery_date is not null
            then datediff(
                day,
                s.ship_date,
                s.delivery_date
            )
        end as transit_days,

        case
            when s.delivery_date is null then null
            when s.delivery_date <= o.promised_date then true
            else false
        end as is_on_time_delivery,

        case
            when s.delivery_date is null then null
            else greatest(
                datediff(
                    day,
                    o.promised_date,
                    s.delivery_date
                ),
                0
            )
        end as delivery_delay_days,

        greatest(
            s.loaded_at,
            o.loaded_at
        ) as record_loaded_at,

        s.airflow_run_id

    from shipments s

    inner join orders o
        on s.order_id = o.order_id

)

select *
from final
