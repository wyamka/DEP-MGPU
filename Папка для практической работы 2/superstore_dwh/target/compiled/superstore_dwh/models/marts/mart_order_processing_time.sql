SELECT
    p.sub_category,
    AVG(s.ship_date - s.order_date) AS avg_processing_days
FROM "superstore"."dw_test"."sales_fact" AS f
LEFT JOIN "superstore"."dw_test"."product_dim" AS p 
    ON f.prod_id = p.prod_id
LEFT JOIN "superstore"."stg"."stg_orders" AS s
    ON f.order_id = s.order_id
GROUP BY p.sub_category
ORDER BY avg_processing_days DESC
LIMIT 5