-- macros/cents_to_currency.sql
-- Converts cents to currency with 2 decimal places
-- Usage: {{ cents_to_currency('amount_in_cents') }}

{% macro cents_to_currency(column_name) %}
    round(cast({{ column_name }} as decimal(18,2)) / 100, 2)
{% endmacro %}