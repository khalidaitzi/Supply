with source as (

    select *
    from {{ source('supply', 'order_lines') }}

),

normalized as (

    select
        trim(order_line_id) as order_line_id,
        trim(order_id) as order_id,
        trim(product_id) as product_id,
        quantity::integer as quantity,
        unit_price::number(18, 2) as unit_price,
        discount_pct::number(10, 4) as discount_pct,
        line_amount::number(18, 2) as line_amount,

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
        partition by order_line_id
        order by loaded_at desc, source_row_number desc
    ) = 1

)

select *
from deduplicated
