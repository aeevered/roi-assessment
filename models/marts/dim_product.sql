select
    product_id,
    product_name,
    category,
    brand
from {{ ref('stg_marketplace__product') }}

