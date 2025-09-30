-- Савкина Мария st_84 Вариант 25
-- Задание 1: [Создать представление по регионам]
CREATE VIEW dw.region AS
SELECT 
    o.region,
    o.country,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    SUM(f.quantity) AS total_quantity,
    AVG(f.discount) AS avg_discount
FROM dw.sales_fact f
JOIN stg.orders o 
    ON f.order_id = o.order_id
GROUP BY o.region, o.country;



-- Задание 2: [Определить возвраты по менеджерам]
CREATE TABLE dw.return_people AS
SELECT 
    p.person AS manager,
    p.region,
    COUNT(r.order_id) AS total_returns,
    SUM(o.sales) AS returned_sales,
    SUM(o.profit) AS returned_profit
FROM public.returns r
JOIN stg.orders o 
    ON r.order_id = o.order_id
JOIN public.people p
    ON o.region = p.region
GROUP BY p.person, p.region;


-- Задание 3: [Рассчитать среднюю скидку по сегментам]
SELECT
  o.segment,
  ROUND(AVG(sf.discount), 4) AS avg_discount,
  COUNT(*) AS orders_count
FROM dw.sales_fact sf
JOIN public.orders o
  ON sf.order_id = o.order_id
WHERE sf.discount IS NOT NULL
GROUP BY o.segment
ORDER BY avg_discount DESC;
