WITH monthly_amounts AS (
    SELECT report_date, SUM(amount) AS total_amount
    FROM (
        SELECT DATE_TRUNC('month', created_at) AS report_date, amount AS amount
        FROM {{ ref('cleaned_orders') }}
        UNION ALL
        SELECT DATE_TRUNC('month', shipped_at) AS report_date, -amount AS amount
        FROM {{ ref('cleaned_orders') }}
        WHERE shipped_at IS NOT NULL
    ) AS order_events
    GROUP BY report_date
)
,date_series AS (
    SELECT generate_series(
        (SELECT MIN(report_date) FROM monthly_amounts),
        (SELECT MAX(report_date) FROM monthly_amounts),
        '1 month'::interval
    ) AS report_date
)
SELECT date_series.report_date,
    SUM(COALESCE(total_amount, 0)) OVER (ORDER BY report_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_amount
FROM date_series
LEFT JOIN monthly_amounts USING(report_date)
ORDER BY report_date ASC