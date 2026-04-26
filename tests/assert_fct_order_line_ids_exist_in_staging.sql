select fct.order_line_id
from {{ ref('fct_order_items') }} as fct
left join {{ ref('stg_marketplace__order_line') }} as lines
    on fct.order_line_id = lines.order_line_id
where lines.order_line_id is null
