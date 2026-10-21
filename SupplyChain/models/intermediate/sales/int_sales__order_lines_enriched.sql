with order_lines as (

    select *
    from {{ ref('order_lines') }}

),

orders as (

    select *
    from {{ ref('orders') }}

),

products as (

    select *
    from {{ ref('products') }}

),

final as (

    select
        ol.order_line_id,
        ol.order_id,
        ol.product_id,

        o.customer_id,
        o.warehouse_id,
        o.order_date,
        o.promised_date,
        o.order_status,
        o.sales_channel,
        o.currency_code,

        ol.quantity,
        ol.unit_price,
        ol.discount_pct,
        ol.line_amount as net_sales_amount,

        p.standard_cost,

        ol.quantity
            * ol.unit_price as gross_sales_amount,

        ol.quantity
            * ol.unit_price
            * ol.discount_pct as discount_amount,

        ol.quantity
            * p.standard_cost as total_standard_cost,

        ol.line_amount
            - (ol.quantity * p.standard_cost)
                as gross_margin_amount,

        {{ safe_divide(
            'ol.line_amount - (ol.quantity * p.standard_cost)',
            'ol.line_amount'
        ) }} as gross_margin_rate,

        greatest(
            ol.loaded_at,
            o.loaded_at,
            p.loaded_at
        ) as record_loaded_at,

        ol.airflow_run_id

    from order_lines ol

    inner join orders o
        on ol.order_id = o.order_id

    inner join products p
        on ol.product_id = p.product_id

)

select *
from final
