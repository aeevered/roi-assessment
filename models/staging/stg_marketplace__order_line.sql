with source as (
    select * from {{ source('marketplace', 'order_line') }}
)

select
    order_line_id,
    order_id,
    product_id,
    seller_id,
    quantity,
    unit_price_at_sale
from source

