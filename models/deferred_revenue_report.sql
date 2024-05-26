WITH monthly_amounts AS (
    SELECT "month", SUM(amount) AS total_amount
    FROM (
        SELECT DATE_TRUNC('month', created_at) AS "month", amount AS amount
        FROM {{ ref('cleaned_orders') }}
        UNION ALL
        SELECT DATE_TRUNC('month', shipped_at) AS "month", -amount AS amount
        FROM {{ ref('cleaned_orders') }}
        WHERE shipped_at IS NOT NULL
    ) AS order_events
    GROUP BY "month"
)
,date_series AS (
    SELECT generate_series(
        (SELECT MIN("month") FROM monthly_amounts),
        (SELECT MAX("month") FROM monthly_amounts),
        '1 month'::interval
    ) AS "month"
)
SELECT date_series."month" as report_date,
    SUM(COALESCE(total_amount, 0)) OVER (ORDER BY "month" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_amount
FROM date_series
LEFT JOIN monthly_amounts USING("month")
ORDER BY report_date ASC