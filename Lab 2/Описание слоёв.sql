-- STG СЛОЙ (Staging Layer)
-- Предназначен для временного хранения сырых данных из источников
-- Таблица: stg.orders
-- Описание: Сырые данные о заказах из исходной системы. Отсутствует строгая нормализация, возможны дубликаты.В данном случае слой STG состоит из трех таблиц: stg.orders, stg.people, stg.returns

COMMENT ON TABLE stg.orders IS 'Staging таблица для сырых данных заказов';

-- Структура stg.orders:
-- row_id          INTEGER         -- Технический идентификатор записи
-- order_id        VARCHAR(14)     -- Бизнес-идентификатор заказа (первичный ключ)
-- order_date      DATE            -- Дата оформления заказа
-- ship_date       DATE            -- Дата доставки
-- ship_mode       VARCHAR(14)     -- Способ доставки
-- customer_id     VARCHAR(8)      -- Идентификатор клиента
-- customer_name   VARCHAR(22)     -- Имя клиента
-- segment         VARCHAR(11)     -- Сегмент клиента
-- country         VARCHAR(13)     -- Страна
-- city            VARCHAR(17)     -- Город
-- state           VARCHAR(20)     -- Штат/Регион
-- postal_code     VARCHAR(50)     -- Почтовый индекс
-- region          VARCHAR(7)      -- Регион
-- product_id      VARCHAR(15)     -- Идентификатор товара
-- category        VARCHAR(15)     -- Категория товара
-- subcategory     VARCHAR(11)     -- Подкатегория товара
-- product_name    VARCHAR(122)    -- Наименование товара
-- sales           NUMERIC(9,4)    -- Сумма продажи
-- quantity        INTEGER         -- Количество товара
-- discount        NUMERIC(4,2)    -- Скидка
-- profit          NUMERIC(21,16)  -- Прибыль

COMMENT ON TABLE stg.people IS 'Staging таблица для данных о персонале';

-- Структура stg.people:
-- person          VARCHAR(17)     -- Имя менеджера 
-- region          VARCHAR(7)      -- Регион ответственности

COMMENT ON TABLE stg.returns IS 'Staging таблица для данных о возвратах';

-- Структура stg.returns:
-- returned        VARCHAR(17)     -- Статус возврата
-- order_id        VARCHAR(20)     -- Ссылка на заказ 

-- Связи между таблицами STG слоя:
-- stg.returns.order_id -> stg.orders.order_id (возвраты связаны с заказами)
-- stg.people.region -> stg.orders.region (менеджеры связаны с регионами заказов)

-- DW СЛОЙ (Data Warehouse layer)
-- Предназначен для учёта продаж с ключевыми бизнес-метриками, данные после нормализации, отчистки, стандартизации, дедупликации и т.д.

COMMENT ON TABLE dw.sales_fact IS 'Фактическая таблица продаж в схеме "звезда"';

-- Структура dw.sales_fact:
-- sales_id        SERIAL          -- Суррогатный ключ продажи (первичный ключ)
-- cost_id         INTEGER         -- Ссылка на клиента (внешний ключ -> dw.customer_dim)
-- order_date_id   INTEGER         -- Ссылка на дату заказа (внешний ключ -> dw.calendar_dim)
-- ship_date_id    INTEGER         -- Ссылка на дату доставки (внешний ключ -> dw.calendar_dim)
-- prod_id         INTEGER         -- Ссылка на товар (внешний ключ -> dw.product_dim)
-- ship_id         INTEGER         -- Ссылка на способ доставки (внешний ключ -> dw.shipping_dim)
-- gvo_id          INTEGER         -- Ссылка на местоположение (внешний ключ -> dw.location_dim)
-- order_id        VARCHAR(29)     -- Бизнес-ключ заказа (из исходной системы)
-- sales           NUMERIC(9,4)    -- Сумма продажи (очищенная, неотрицательная)
-- profit          NUMERIC(21,16)  -- Прибыль (рассчитанная и верифицированная)
-- quantity        INTEGER         -- Количество товара (очищенное, неотрицательное)
-- discount        NUMERIC(4,2)    -- Скидка (нормализованная, 0-100%)

-- Таблица: dw.customer_dim
-- Необходима для анализа покупательского поведения клиентов
COMMENT ON TABLE dw.customer_dim IS 'Измерение клиентов с демографическими атрибутами';

-- Структура dw.customer_dim:
-- cost_id         SERIAL          -- Суррогатный ключ клиента (первичный ключ)
-- customers_id    VARCHAR(8)      -- Бизнес-идентификатор клиента (из исходной системы)
-- customers_name  VARCHAR(22)     -- Имя клиента

-- Таблица: dw.product_dim
-- Используется для измерения товаров с иерархией категорий для товарной аналитики
COMMENT ON TABLE dw.product_dim IS 'Измерение товаров с категорийной иерархией';

-- Структура dw.product_dim:
-- prod_id         SERIAL          -- Суррогатный ключ товара (первичный ключ)
-- product_id      VARCHAR(50)     -- Бизнес-идентификатор товара (из исходной системы)
-- product_name    VARCHAR(127)    -- Наименование товара
-- category        VARCHAR(18)     -- Категория товара 
-- sub_category    VARCHAR(11)     -- Подкатегория товара 
-- segment         VARCHAR(11)     -- Сегмент товара 

-- Таблица: dw.location_dim
-- Позволяет осуществлять измерение географических местоположений для пространственного анализа
COMMENT ON TABLE dw.location_dim IS 'Измерение географических местоположений';

-- Структура dw.location_dim:
-- gvo_id          SERIAL          -- Ключ местоположения (первичный ключ)
-- country         VARCHAR(13)     -- Страна
-- city            VARCHAR(17)     -- Город
-- state           VARCHAR(20)     -- Штат/Регион
-- postal_code     VARCHAR(20)     -- Почтовый индекс

-- Связи между таблицами DW слоя:
-- • dw.sales_fact.cost_id -> dw.customer_dim.cost_id (клиенты)
-- • dw.sales_fact.prod_id -> dw.product_dim.prod_id (товары)
-- • dw.sales_fact.gvo_id -> dw.location_dim.gvo_id (местоположения)
-- • dw.sales_fact.ship_id -> dw.shipping_dim.ship_id (доставка)
-- • dw.sales_fact.order_date_id -> dw.calendar_dim.dared (дата заказа)
-- • dw.sales_fact.ship_date_id -> dw.calendar_dim.dared (дата доставки)

-- СЛОВАРИ (DIMENSIONS)
-- Предназначены для хранения справочной информации и контекстных атрибутов, которые обеспечивают многомерный анализ бизнес-процессов
 
-- Таблица: dw.shipping_dim
-- Справочник способов и характеристик доставки
COMMENT ON TABLE dw.shipping_dim IS 'Справочник способов доставки';

-- Структура dw.shipping_dim:
-- ship_id         SERIAL          -- Ключ доставки (первичный ключ)
-- shipping_mode   VARCHAR(14)     -- Способ доставки (Standard Class, Second Class и т.д.)

-- Таблица: dw.calendar_dim
-- Календарное измерение для временного анализа и агрегаций
COMMENT ON TABLE dw.calendar_dim IS 'Календарное измерение для анализа по времени';

-- Структура dw.calendar_dim:
-- dared           SERIAL          -- Ключ даты (первичный ключ)
-- year            INTEGER         -- Год (для годовых агрегаций)
-- quarter         INTEGER         -- Квартал (для квартальной отчетности)
-- month           INTEGER         -- Месяц (для месячного анализа)
-- week            INTEGER         -- Неделя (для недельных трендов)
-- date            DATE            -- Полная дата (для детального анализа)
-- week_day        VARCHAR(20)     -- День недели (для анализа по дням недели)
-- leap            VARCHAR(20)     -- Признак високосного года (для корректных расчетов)