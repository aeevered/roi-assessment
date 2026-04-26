{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
    )
}}

/*
  Example incremental pattern: reprocess only orders newer than what this table already holds.
  On a static seed DB the second run typically appends nothing; the pattern is what you would
  use against an append-only orders stream in production.
*/
select
    order_id,
    customer_id,
    shipping_address_id,
    order_date,
    total_order_amount,
    status
from {{ ref('stg_marketplace__orders') }}

{% if is_incremental %}
where order_date > (select coalesce(max(order_date), '1970-01-01'::timestamptz) from {{ this }})
{% endif %}
