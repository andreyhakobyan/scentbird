WITH monthly_report AS (
    SELECT DATE_TRUNC('month', created_at) AS report_date, SUM(amount) AS total_amount
    FROM {{ ref('cleaned_orders') }}
    WHERE shipped_at IS NULL
    GROUP BY DATE_TRUNC('month', created_at)
)
,date_series AS (
    SELECT generate_series(
        (SELECT MIN(DATE_TRUNC('month', created_at)) FROM {{ ref('cleaned_orders') }}),
        (SELECT MAX(DATE_TRUNC('month', created_at)) FROM {{ ref('cleaned_orders') }}),
        '1 month'::interval
    ) AS report_date
)
SELECT date_series.report_date, COALESCE(monthly_report.total_amount, 0) AS total_amount
FROM date_series
LEFT JOIN monthly_report USING(report_date)
ORDER BY date_series.report_date ASC