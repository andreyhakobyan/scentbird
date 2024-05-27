WITH advertising AS (
    SELECT created_at AS campaign_start
        ,created_at + INTERVAL '24 hours' AS campaign_end
        ,lower(params ->> 'utm_campaign') AS campaign_name
    FROM {{ source('public_exercises', 'events') }}
    WHERE event_name = 'AdvertisingCampaignSet'
),
first_campaign_orders AS (
    SELECT advertising.campaign_name,
        cleaned_orders.amount,
        ROW_NUMBER() OVER (PARTITION BY cleaned_orders.id ORDER BY cleaned_orders.created_at) AS row_num
    FROM advertising
    LEFT JOIN {{ ref('cleaned_orders') }} ON cleaned_orders.created_at BETWEEN advertising.campaign_start AND advertising.campaign_end
)
SELECT campaign_name, SUM(amount) AS total_revenue
FROM first_campaign_orders
WHERE row_num = 1
GROUP BY campaign_name