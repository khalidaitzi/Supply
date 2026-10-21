with source as (

    select *
    from {{ source('supply', 'products') }}

),

normalized as (

    select
        trim(product_id) as product_id,
        trim(product_name) as product_name,
        upper(trim(category)) as product_category,
        upper(trim(subcategory)) as product_subcategory,
        standard_cost::number(18, 2) as standard_cost,
        list_price::number(18, 2) as list_price,
        weight_kg::number(18, 3) as weight_kg,
        upper(trim(active_flag)) = 'Y' as is_active,

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
        partition by product_id
        order by loaded_at desc, source_row_number desc
    ) = 1

)

select *
from deduplicated
