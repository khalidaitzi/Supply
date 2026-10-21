{% macro get_run_id() %}

    '{{ var("airflow_run_id", invocation_id) }}'

{% endmacro %}
