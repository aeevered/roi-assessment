with source as (
    select * from {{ source('marketplace', 'customer') }}
)

select
    customer_id,
    first_name,
    last_name,
    email,
    created_at
from source

