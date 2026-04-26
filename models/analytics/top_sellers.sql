with aggregated_by_seller as (
    select
        seller_id,
        sum(item_amount) as gross_revenue,
        sum(quantity) as units_sold,
        count(distinct order_id) as orders
    from {{ ref('fct_order_items') }} AS order_items
    group by seller_id
),

aggregated_with_seller_details as (
    select
        aggregated_by_seller.*,
        seller.store_name
    from aggregated_by_seller
    left join {{ ref('dim_seller') }} as seller
        on aggregated_by_seller.seller_id = seller.seller_id
),

ranked as (
    select
        aggregated_with_seller_details.*,
        dense_rank() over (order by gross_revenue desc) as gross_revenue_rank,
        dense_rank() over (order by units_sold desc) as units_sold_rank,
        dense_rank() over (order by orders desc) as orders_rank
    from aggregated_with_seller_details
)

select *
from ranked
order by gross_revenue desc

