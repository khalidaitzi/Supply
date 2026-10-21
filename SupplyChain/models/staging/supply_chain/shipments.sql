with source as (

    select *
    from {{ source('supply', 'shipments') }}

),

normalized as (

    select
        trim(shipment_id) as shipment_id,
        trim(order_id) as order_id,
        trim(carrier_id) as carrier_id,
        ship_date::date as ship_date,
        delivery_date::date as delivery_date,
        freight_cost::number(18, 2) as freight_cost,
        upper(trim(shipment_status)) as shipment_status,
        trim(tracking_number) as tracking_number,

        _source_file as source_file_name,
        _source_row_number as source_row_number,
        _file_checksum as source_file_checksum,
        _file_last_modified as source_file_last_modified_at,
        _loaded_at as loaded_at,
        _airflow_run_id as airflow_run_id

    from source

),

deduplicated as (

    select *
    from normalized

    qualify row_number() over (
        partition by shipment_id
        order by loaded_at desc, source_row_number desc
    ) = 1

)

select *
from deduplicated
