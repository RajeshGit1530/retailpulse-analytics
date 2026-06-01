-- macros/generate_hash_key.sql
-- Generates MD5 hash key from one or more columns
-- Usage: {{ generate_hash_key(['col1', 'col2']) }}

{% macro generate_hash_key(columns) %}
    md5(
        {% for col in columns %}
            coalesce(cast({{ col }} as varchar), 'NULL')
            {% if not loop.last %} || '||' || {% endif %}
        {% endfor %}
    )
{% endmacro %}