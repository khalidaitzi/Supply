with source as (

    select *
    from {{ source('supply', 'warehouses') }}

),

normalized as (

    select
        trim(warehouse_id) as warehouse_id,
        trim(warehouse_name) as warehouse_name,
        trim(country) as country,
        trim(region) as region,
        capacity_units::integer as capacity_units,

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
        partition by warehouse_id
        order by
            loaded_at desc,
            source_file_last_modified_at desc,
            source_row_number desc
    ) = 1

)

select *
from deduplicated
