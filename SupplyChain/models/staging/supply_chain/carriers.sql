with source as (

    select *
    from {{ source('supply', 'carriers') }}

),

normalized as (

    select
        trim(carrier_id) as carrier_id,
        trim(carrier_name) as carrier_name,
        upper(trim(service_level)) as service_level,

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
        partition by carrier_id
        order by
            loaded_at desc,
            source_file_last_modified_at desc,
            source_row_number desc
    ) = 1

)

select *
from deduplicated
