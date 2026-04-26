with source as (
    select * from {{ source('marketplace', 'orders') }}
)

select
    order_id,
    customer_id,
    shipping_address_id,
    order_date,
    total_order_amount,
    status
from source

