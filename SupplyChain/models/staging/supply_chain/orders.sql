with source as (

    select *
    from {{ source('supply', 'orders') }}

),

normalized as (

    select
        trim(order_id) as order_id,
        trim(customer_id) as customer_id,
        trim(warehouse_id) as warehouse_id,
        order_date::date as order_date,
        promised_date::date as promised_date,
        upper(trim(order_status)) as order_status,
        upper(trim(sales_channel)) as sales_channel,
        upper(trim(currency)) as currency_code,
        updated_at::timestamp_ntz as source_updated_at,

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
        partition by order_id
        order by source_updated_at desc, loaded_at desc
    ) = 1

)

select *
from deduplicated
