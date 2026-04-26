select
    seller_id,
    store_name,
    rating,
    joined_date
from {{ ref('stg_marketplace__seller') }}

