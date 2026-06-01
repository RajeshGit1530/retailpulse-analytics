{% snapshot snap_products %}

{{
    config(
        target_database='RETAILPULSE_SNAPSHOTS',
        target_schema='SNAPSHOTS',
        unique_key='product_id',
        strategy='timestamp',
        updated_at='updated_at'
    )
}}

select
    product_id,
    product_name,
    product_sku,
    category,
    subcategory,
    brand,
    cost_price,
    selling_price,
    is_active,
    updated_at

from {{ source('retailpulse_landing', 'raw_products') }}

{% endsnapshot %}