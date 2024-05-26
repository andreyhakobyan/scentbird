WITH daily_amounts AS (
    SELECT event_time, SUM(amount) AS total_amount
    FROM (
        SELECT created_at::date AS event_time, amount AS amount
        FROM {{ ref('cleaned_orders') }}
        UNION ALL
        SELECT shipped_at::date AS event_time, -amount AS amount
        FROM {{ ref('cleaned_orders') }}
        WHERE shipped_at IS NOT NULL
    ) AS order_events
    GROUP BY event_time
)
,date_series AS (
    SELECT generate_series(
        (SELECT MIN(event_time)::date FROM daily_amounts),
        (SELECT MAX(event_time)::date FROM daily_amounts),
        '1 day'::interval
    )::date AS event_time
)
SELECT date_series.event_time AS report_date,
    SUM(COALESCE(total_amount, 0)) OVER (ORDER BY event_time ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_amount
FROM date_series
LEFT JOIN daily_amounts USING(event_time)
ORDER BY report_date ASC