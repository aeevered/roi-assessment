{% snapshot scd_seller_product_price %}

{{
    config(
        unique_key='seller_product_key',
        strategy='timestamp',
        updated_at='updated_at',
    )
}}

/*
  Type 2 SCD example: track changes to seller_product_price over time using the source
  updated_at column (timestamp strategy). Each change creates a new snapshot row with
  dbt_valid_from / dbt_valid_to.
*/
select
    seller_id,
    product_id,
    (seller_id::text || '|' || product_id::text) as seller_product_key,
    current_price,
    stock_quantity,
    updated_at
from {{ source('marketplace', 'seller_product_price') }}

{% endsnapshot %}
