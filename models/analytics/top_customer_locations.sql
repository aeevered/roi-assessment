with aggregated_by_location as (
    select
        customer_address.city,
        customer_address.state,
        count(distinct order_items.customer_id) as customers,
        count(distinct order_items.order_id) as orders,
        sum(order_items.item_amount) as gross_revenue
    from {{ ref('fct_order_items') }} as order_items
    left join {{ ref('dim_customer_address') }} as customer_address
        on order_items.address_id = customer_address.address_id
    group by customer_address.city, customer_address.state
),

ranked as (
    select
        aggregated_by_location.*,
        dense_rank() over (order by gross_revenue desc) as gross_revenue_rank,
        dense_rank() over (order by customers desc) as customers_rank,
        dense_rank() over (order by orders desc) as orders_rank
    from aggregated_by_location
)

select *
from ranked
order by gross_revenue desc

