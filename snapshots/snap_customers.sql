{% snapshot snap_customers %}

{{
    config(
        target_database='RETAILPULSE_SNAPSHOTS',
        target_schema='SNAPSHOTS',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_at'
    )
}}

select
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    customer_segment,
    city,
    state,
    country,
    is_active,
    updated_at

from {{ source('retailpulse_landing', 'raw_customers') }}

{% endsnapshot %}