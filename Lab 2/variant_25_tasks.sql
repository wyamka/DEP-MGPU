-- Савкина Мария st_84 Вариант 25
-- Задание 1: [Создать представление по регионам]

-- REGION VIEW
CREATE VIEW dw.region AS
-- Вывод данных о сумме продаж, общей прибыли, числе проданных товаров и среднем размере скидки в регионе из таблицы dw.sales_fact
SELECT 
    o.region,
    o.country,
    SUM(f.sales) AS total_sales,
    SUM(f.profit) AS total_profit,
    SUM(f.quantity) AS total_quantity,
    AVG(f.discount) AS avg_discount
FROM dw.sales_fact f
-- Получение геоданых из stg.orders o
JOIN stg.orders o 
    ON f.order_id = o.order_id
-- Группировка по региону и стране
GROUP BY o.region, o.country;





-- Задание 2: [Определить возвраты по менеджерам]

-- RETURN PEOPLE
CREATE TABLE dw.return_people AS
-- Возвращенные товары (количество, сумма продаж и прибыли)
SELECT 
    p.person AS manager,
    p.region,
    COUNT(r.order_id) AS total_returns,
    SUM(o.sales) AS returned_sales,
    SUM(o.profit) AS returned_profit
FROM public.returns r
-- Подключение таблицы заказов (для финансов) и таблицы персонала (для определения менеджеров)
JOIN stg.orders o 
    ON r.order_id = o.order_id
JOIN public.people p
    ON o.region = p.region
 -- Группировка по менеджеру и региону
GROUP BY p.person, p.region;




-- Задание 3: [Рассчитать среднюю скидку по сегментам]

-- SEGMENT SALE
-- Общая скидка (округляем до 4 знака для точности), общее количество заказов в данном сегменте
SELECT
  o.segment,
  ROUND(AVG(sf.discount), 4) AS avg_discount,
  COUNT(*) AS orders_count
FROM dw.sales_fact sf
-- Данные о сегментах из таблицы заказов
JOIN public.orders o
  ON sf.order_id = o.order_id
-- Фильтруем записи с указанной скидкой, группируем по сегментам, сортируем по убыванию 
WHERE sf.discount IS NOT NULL
GROUP BY o.segment
ORDER BY avg_discount DESC;
