-- models/core/dim_customers.sql
WITH shopify_cust AS (
  SELECT
    id                   AS customer_id,
    email                AS email,
    first_name           AS first_name,
    last_name            AS last_name,
    created_at           AS signup_date
  FROM raw.shopify_customers
),
klaviyo_prof AS (
  SELECT
    profile_id           AS klaviyo_id,
    email                AS email,
    CASE
      WHEN subscribed = true THEN 'Subscribed'
      ELSE 'Unsubscribed'
    END                   AS subscription_status
  FROM raw.klaviyo_profiles
),
ga_users AS (
  SELECT
    user_pseudo_id       AS ga_user_id,
    user_properties ->> 'email' AS email
  FROM raw.ga4_user_data
)
SELECT
  sc.customer_id,
  sc.email,
  sc.first_name,
  sc.last_name,
  sc.signup_date,
  kp.subscription_status,
  gu.ga_user_id,
  -- Example loyalty tier logic
  CASE
    WHEN COUNT(o.id) OVER (PARTITION BY sc.customer_id) > 10 THEN 'Gold'
    WHEN COUNT(o.id) OVER (PARTITION BY sc.customer_id) >  5 THEN 'Silver'
    ELSE 'Bronze'
  END                   AS loyalty_tier
FROM shopify_cust sc
LEFT JOIN klaviyo_prof kp
  ON sc.email = kp.email
LEFT JOIN ga_users gu
  ON sc.email = gu.email
LEFT JOIN raw.shopify_orders o
  ON sc.customer_id = o.customer_id;
