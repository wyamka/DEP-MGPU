-- Савкина Мария

-- Количество записей в источнике и приёмнике (вывод обоих значения)

SELECT 
    (SELECT COUNT(*) FROM stg.orders) AS cnt_stg_orders,
    (SELECT COUNT(*) FROM dw.sales_fact) AS cnt_sales_fact;

-- Проверка данных (по категориям)

SELECT category, COUNT(*) AS cnt_products
FROM dw.product_dim
GROUP BY category
ORDER BY cnt_products DESC;

-- Проверка данных (по сегментам)

SELECT segment, COUNT(*) AS cnt_orders
FROM stg.orders
GROUP BY segment;

-- ПРОВЕРКА ОТСУТСТВИЯ ДУБЛИКАТОВ

-- У клиентов

SELECT customer_id, COUNT(*) AS cnt
FROM dw.customer_dim
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Для продуктов

SELECT product_id, COUNT(*) AS cnt
FROM dw.product_dim
GROUP BY product_id
HAVING COUNT(*) > 1;

--ССЫЛОЧНАЯ ЦЕЛОСТНОСТЬ

-- Клиенты
SELECT COUNT(*) AS missing_customers
FROM dw.sales_fact f
LEFT JOIN dw.customer_dim c ON f.cust_id = c.cust_id
WHERE c.cust_id IS NULL;

-- Продукты
SELECT COUNT(*) AS missing_products
FROM dw.sales_fact f
LEFT JOIN dw.product_dim p ON f.prod_id = p.prod_id
WHERE p.prod_id IS NULL;

-- Даты
SELECT COUNT(*) AS missing_dates
FROM dw.sales_fact f
LEFT JOIN dw.calendar_dim d ON f.order_date_id = d.dateid
WHERE d.dateid IS NULL;

-- КОРРЕКТНОСТЬ РАСЧЕТОВ

-- Корректность агрегатов

-- Источник
SELECT 
    SUM(sales)  AS total_sales,
    SUM(profit) AS total_profit
FROM stg.orders;

-- Приёмник
SELECT 
    SUM(sales)  AS total_sales,
    SUM(profit) AS total_profit
FROM dw.sales_fact;

-- Сверка контрольных сумм между источником (stg.orders) и витриной (dw.sales_fact)

-- Проверка количества заказов
SELECT 'orders_count' AS metric, 
       (SELECT COUNT(*) FROM stg.orders)    AS stg_value,  
       (SELECT COUNT(*) FROM dw.sales_fact) AS dw_value 

UNION ALL
-- Проверка суммы продаж
SELECT 'sales_sum',
       (SELECT SUM(sales) FROM stg.orders),            
       (SELECT SUM(sales) FROM dw.sales_fact)        

UNION ALL
-- Проверка суммы прибыли
SELECT 'profit_sum',
       (SELECT SUM(profit) FROM stg.orders),          
       (SELECT SUM(profit) FROM dw.sales_fact)        

UNION ALL
-- Проверка суммы скидок
SELECT 'discount_sum',
       (SELECT SUM(discount) FROM stg.orders),  
       (SELECT SUM(discount) FROM dw.sales_fact)    

UNION ALL
-- Проверка общего количества единиц товара
SELECT 'quantity_sum',
       (SELECT SUM(quantity) FROM stg.orders),    
       (SELECT SUM(quantity) FROM dw.sales_fact);	


-- ДОПОЛНИТЕЛЬНЫЕ ПРОВЕРКИ

-- Проверка На Отрицательные Значения (Где Они Недопустимы)

-- Сумма продаж

SELECT 
    'Negative Sales' as check_type,
    COUNT(*) as problematic_records
FROM dw.sales_fact 
WHERE sales < 0;

-- Количество товара

SELECT 
    'Negative Quantity' as check_type,
    COUNT(*) as problematic_records
FROM dw.sales_fact 
WHERE quantity < 0;
