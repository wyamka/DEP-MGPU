SELECT
    p.sub_category,
    AVG(s.ship_date - s.order_date) AS avg_processing_days
FROM {{ ref('sales_fact') }} AS f
LEFT JOIN {{ ref('product_dim') }} AS p 
    ON f.prod_id = p.prod_id
LEFT JOIN {{ ref('stg_orders') }} AS s
    ON f.order_id = s.order_id
GROUP BY p.sub_category
ORDER BY avg_processing_days DESC
LIMIT 5