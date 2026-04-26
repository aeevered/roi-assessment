with source as (
    select * from {{ source('marketplace', 'product') }}
)

select
    product_id,
    product_name,
    category,
    brand
from source

