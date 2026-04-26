with customers as (
    select * from {{ ref('stg_marketplace__customer') }}
),

addresses as (
    select * from {{ ref('stg_marketplace__customer_address') }}
),

default_address as (
    select
        customer_id,
        address_id,
        address_line_1,
        city,
        state,
        zip_code,
        is_default_shipping,
        row_number() over (
            partition by customer_id
            order by
                case when is_default_shipping then 0 else 1 end,
                address_id
        ) as address_rank
    from addresses
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.created_at,
    a.address_id as default_address_id,
    a.address_line_1 as default_address_line_1,
    a.city as default_city,
    a.state as default_state,
    a.zip_code as default_zip_code
from customers c
left join default_address a
    on c.customer_id = a.customer_id
   and a.address_rank = 1

