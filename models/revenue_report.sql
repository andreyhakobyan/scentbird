SELECT DATE_TRUNC('month', shipped_at) AS report_date
    ,SUM(amount) AS total_amount
FROM {{ ref('cleaned_orders') }}
WHERE shipped_at IS NOT NULL
GROUP BY report_date
ORDER BY report_date
