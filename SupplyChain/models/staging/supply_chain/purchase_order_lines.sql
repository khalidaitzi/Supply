with source as (

    select *
    from {{ source(
        'supply',
        'purchase_order_lines'
    ) }}

),

normalized as (

    select
        trim(po_line_id) as po_line_id,

        trim(purchase_order_id)
            as purchase_order_id,

        trim(product_id) as product_id,

        ordered_qty::integer as ordered_qty,
        received_qty::integer as received_qty,
        unit_cost::number(18, 2) as unit_cost,

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
        partition by po_line_id
        order by
            loaded_at desc,
            source_file_last_modified_at desc,
            source_row_number desc
    ) = 1

)

select *
from deduplicated
