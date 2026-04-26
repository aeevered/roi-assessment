with source as (
    select * from {{ source('marketplace', 'customer_address') }}
)

select
    address_id,
    customer_id,
    address_line_1,
    city,
    state,
    zip_code,
    is_default_shipping
from source

