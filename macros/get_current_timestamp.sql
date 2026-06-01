-- macros/get_current_timestamp.sql
-- Returns current timestamp in UTC
-- Usage: {{ get_current_timestamp() }}

{% macro get_current_timestamp() %}
    convert_timezone('UTC', current_timestamp())
{% endmacro %}