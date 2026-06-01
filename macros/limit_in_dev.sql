-- macros/limit_in_dev.sql
-- Limits rows in dev environment to avoid heavy processing
-- Usage: {{ limit_in_dev(100) }}

{% macro limit_in_dev(row_limit=100) %}
    {% if target.name == 'dev' %}
        limit {{ row_limit }}
    {% endif %}
{% endmacro %}