with source as (
    select * from {{ source('marketplace', 'seller') }}
)

select
    seller_id,
    store_name,
    rating,
    joined_date
from source

