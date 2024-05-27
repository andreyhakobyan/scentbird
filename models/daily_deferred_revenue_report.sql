WITH daily_amounts AS (
    SELECT report_date, SUM(amount) AS total_amount
    FROM (
        SELECT created_at::date AS report_date, amount
        FROM {{ ref('cleaned_orders') }}
        UNION ALL
        SELECT shipped_at::date AS report_date, -amount
        FROM {{ ref('cleaned_orders') }}
        WHERE shipped_at IS NOT NULL
    ) AS order_events
    GROUP BY report_date
)
,date_series AS (
    SELECT generate_series(
        (SELECT MIN(report_date)::date FROM daily_amounts),
        (SELECT MAX(report_date)::date FROM daily_amounts),
        '1 day'::interval
    )::date AS report_date
)
SELECT date_series.report_date,
    SUM(COALESCE(total_amount, 0)) OVER (ORDER BY report_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_amount
FROM date_series
LEFT JOIN daily_amounts USING(report_date)
ORDER BY report_date ASC