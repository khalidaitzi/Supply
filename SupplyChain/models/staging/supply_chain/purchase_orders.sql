with source as (

    select *
    from {{ source(
        'supply',
        'purchase_orders'
    ) }}

),

normalized as (

    select
        trim(purchase_order_id)
            as purchase_order_id,

        trim(supplier_id) as supplier_id,
        trim(warehouse_id) as warehouse_id,

        order_date::date as order_date,
        expected_date::date as expected_date,
        received_date::date as received_date,

        upper(trim(po_status)) as purchase_order_status,

        _source_file as source_file_name,
        _source_row_number as source_row_number,
        _file_checksum as source_file_checksum,
        _file_last_modified
            as source_file_last_modified_at,
        _loaded_at as loaded_at,
        _airflow_run_id as airflow_run_id

    from source

),

deduplicated as (

    select *
    from normalized

    qualify row_number() over (
        partition by purchase_order_id
        order by
            loaded_at desc,
            source_file_last_modified_at desc,
            source_row_number desc
    ) = 1

)

select *
from deduplicated
