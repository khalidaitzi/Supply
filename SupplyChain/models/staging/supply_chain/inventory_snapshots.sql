with source as (

    select *
    from {{ source(
        'supply',
        'inventory_snapshots'
    ) }}

),

normalized as (

    select
        snapshot_date::date as snapshot_date,
        trim(warehouse_id) as warehouse_id,
        trim(product_id) as product_id,

        on_hand_qty::integer as on_hand_qty,
        allocated_qty::integer as allocated_qty,
        available_qty::integer as available_qty,
        reorder_point::integer as reorder_point,

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
        partition by
            snapshot_date,
            warehouse_id,
            product_id

        order by
            loaded_at desc,
            source_file_last_modified_at desc,
            source_row_number desc
    ) = 1

)

select *
from deduplicated
