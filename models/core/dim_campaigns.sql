-- models/core/dim_campaigns.sql

WITH meta_campaigns AS (
  SELECT
    campaign_id           AS campaign_id,
    campaign_name         AS campaign_name,
    campaign_status       AS status,
    objective             AS objective
  FROM raw.facebook_ad_campaigns
),
klaviyo_campaigns AS (
  SELECT
    campaign_id           AS campaign_id,
    name                  AS campaign_name,
    type                  AS klaviyo_type
  FROM raw.klaviyo_campaigns
)
SELECT
  COALESCE(mc.campaign_id, kc.campaign_id)      AS campaign_id,
  COALESCE(mc.campaign_name, kc.campaign_name)  AS campaign_name,
  -- Classify type
  CASE
    WHEN mc.objective ILIKE '%CONVERSIONS%' THEN 'Conversion'
    WHEN mc.objective ILIKE '%AWARENESS%'   THEN 'Awareness'
    WHEN kc.klaviyo_type = 'flow'            THEN 'Loyalty'
    ELSE 'Other'
  END                                           AS campaign_type,
  COALESCE(mc.status, 'unknown')               AS status,
  CURRENT_TIMESTAMP()                          AS updated_at
FROM meta_campaigns mc
FULL OUTER JOIN klaviyo_campaigns kc
  ON mc.campaign_id = kc.campaign_id;
