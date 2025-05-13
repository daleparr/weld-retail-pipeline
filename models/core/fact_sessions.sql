-- models/core/fact_sessions.sql

WITH sessions_base AS (
  SELECT
    user_pseudo_id        AS ga_user_id,
    event_timestamp       AS session_start_ts,
    (event_timestamp + (engagement_time_msec * INTERVAL '1 millisecond')) 
                           AS session_end_ts,
    geo.country           AS country,
    device.category       AS device_category
  FROM raw.ga4_sessions
),
events AS (
  SELECT
    user_pseudo_id        AS ga_user_id,
    event_name            AS event_name,
    event_timestamp       AS event_ts,
    ecommerce.transaction_id AS ga_order_id
  FROM raw.ga4_events
  WHERE event_name IN ('page_view', 'purchase', 'add_to_cart')
)
SELECT
  sb.ga_user_id,
  sb.session_start_ts,
  sb.session_end_ts,
  sb.country,
  sb.device_category,
  e.event_name,
  e.event_ts,
  e.ga_order_id,
  CURRENT_TIMESTAMP()   AS updated_at
FROM sessions_base sb
LEFT JOIN events e
  ON sb.ga_user_id = e.ga_user_id
 AND e.event_ts BETWEEN sb.session_start_ts 
                    AND sb.session_end_ts;
