with aggregated_by_product as (
    select
        product_id,
        sum(item_amount) as gross_revenue,
        sum(quantity) as units_sold,
        count(distinct order_id) as orders
    from {{ ref('fct_order_items') }} as order_items
    group by product_id
),

aggregated_with_product_details as (
    select
        aggregated_by_product.*,
        product.product_name,
        product.category,
        product.brand
    from aggregated_by_product
    left join {{ ref('dim_product') }} as product
        on aggregated_by_product.product_id = product.product_id
),

ranked as (
    select
        aggregated_with_product_details.*,
        dense_rank() over (order by gross_revenue desc) as gross_revenue_rank,
        dense_rank() over (order by units_sold desc) as units_sold_rank,
        dense_rank() over (order by orders desc) as orders_rank
    from aggregated_with_product_details
)

select *
from ranked
order by gross_revenue desc

