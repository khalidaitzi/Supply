with source as (

    select *
    from {{ source('supply', 'suppliers') }}

),

normalized as (

    select
        trim(supplier_id) as supplier_id,
        trim(supplier_name) as supplier_name,
        trim(country) as country,
        upper(trim(risk_tier)) as risk_tier,
        default_lead_time_days::integer
            as default_lead_time_days,

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
        partition by supplier_id
        order by
            loaded_at desc,
            source_file_last_modified_at desc,
            source_row_number desc
    ) = 1

)

select *
from deduplicated
