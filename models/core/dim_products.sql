-- models/core/dim_products.sql
WITH base AS (
  SELECT
    id                        AS product_id,
    title                     AS product_name,
    tags                      AS tags_list
  FROM raw.shopify_products
),
variants AS (
  SELECT
    product_id,
    title                     AS variant_title,
    metafields -> 'fabric'    AS fabric_type
  FROM raw.shopify_product_variants
)
SELECT
  b.product_id,
  b.product_name,
  -- Classify tier based on tags
  CASE
    WHEN b.tags_list LIKE '%Hero%'     THEN 'Hero'
    WHEN b.tags_list LIKE '%Accessory%' THEN 'Accessory'
    ELSE 'Staple'
  END                                        AS product_tier,
  v.variant_title                           AS fit_type,
  v.fabric_type                             AS fabric_type,
  CURRENT_TIMESTAMP()                       AS updated_at
FROM base b
LEFT JOIN variants v
  ON b.product_id = v.product_id;
