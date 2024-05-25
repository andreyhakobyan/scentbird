/*
Since the number of duplicates in the `id` column is equal to the number of duplicates in all columns,
accordingly we can remove duplicates by `id`. Also table `orders` contain NULL values in column amount, so
we should need to delete that rows.
*/

SELECT id
    ,user_id
    ,amount
    ,created_at
    ,shipped_at
FROM (
    SELECT id
        ,user_id
        ,amount
        ,created_at
        ,shipped_at
        ,ROW_NUMBER() OVER (PARTITION BY id) as rn
    FROM {{ source('public_exercises', 'orders') }}
) AS ranked_orders
WHERE rn = 1 AND amount IS NOT NULL
