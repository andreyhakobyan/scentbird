SELECT DATE_TRUNC('month', created_at) AS report_date
  ,SUM(CASE WHEN shipped_at IS NULL THEN amount ELSE 0 END) AS total_amount
FROM {{ ref('cleaned_orders') }}
GROUP BY report_date
ORDER BY report_date
