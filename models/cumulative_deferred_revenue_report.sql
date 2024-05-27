SELECT report_date,
    SUM(COALESCE(total_amount, 0)) OVER (ORDER BY report_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_amount
FROM {{ ref("deferred_revenue_report") }}
ORDER BY report_date ASC