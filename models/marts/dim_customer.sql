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
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customers.email,
    customers.created_at,
    address.address_id as default_address_id,
    address.address_line_1 as default_address_line_1,
    address.city as default_city,
    address.state as default_state,
    address.zip_code as default_zip_code
from customers
left join default_address as address
    on customers.customer_id = address.customer_id
   and address.address_rank = 1

