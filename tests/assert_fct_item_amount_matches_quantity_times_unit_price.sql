select order_line_id
from {{ ref('fct_order_items') }}
where item_amount is null
   or item_amount <> (quantity * unit_price_at_sale)::numeric(12, 2)
