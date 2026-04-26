with source as (
    select * from {{ source('marketplace', 'seller_product_price') }}
)

select
    seller_id,
    product_id,
    current_price,
    stock_quantity,
    updated_at
from source

