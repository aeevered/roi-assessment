select
    customer_id,
    address_id,
    address_line_1,
    city,
    state,
    zip_code,
    is_default_shipping
from {{ ref('stg_marketplace__customer_address') }}

