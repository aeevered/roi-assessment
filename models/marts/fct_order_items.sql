with orders as (
    select * from {{ ref('stg_marketplace__orders') }}
    where status is not 'cancelled'
),

items as (
    select * from {{ ref('stg_marketplace__order_line') }}
),

joined as (
    select
        items.order_line_id,
        items.order_id,
        orders.customer_id,
        orders.shipping_address_id as address_id,
        items.product_id,
        items.seller_id,
        orders.order_date,
        orders.status,
        items.quantity,
        items.unit_price_at_sale,
        (items.quantity * items.unit_price_at_sale)::numeric(12, 2) as item_amount
    from items
    inner join orders
        on items.order_id = orders.order_id
)

select * from joined

