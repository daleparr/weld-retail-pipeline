-- models/core/fact_orders.sql

WITH orders_base AS (
  SELECT
    o.id                        AS order_id,
    o.customer_id               AS customer_id,
    o.created_at                AS order_date,
    o.total_price               AS order_total,
    o.currency                  AS currency
  FROM raw.shopify_orders o
),
line_items AS (
  SELECT
    order_id,
    product_id,
    quantity,
    price                      AS line_price
  FROM raw.shopify_order_line_items
)
SELECT
  ob.order_id,
  ob.customer_id,
  ob.order_date,
  ob.order_total,
  ob.currency,
  li.product_id,
  li.quantity,
  li.line_price,
  -- Compute average price per item
  (ob.order_total / NULLIF(SUM(li.quantity) OVER (PARTITION BY ob.order_id), 0)) 
    AS avg_item_price,
  CURRENT_TIMESTAMP()          AS updated_at
FROM orders_base ob
LEFT JOIN line_items li
  ON ob.order_id = li.order_id;
