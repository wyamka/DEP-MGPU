# 🧾 Результаты проверок 

---

## 📁 Содержимое директории

| Файл | Описание проверки |
|------|--------------------|
| [Correct_agregator_istochnik.csv](./Correct_agregator_istochnik.csv) | Проверка корректности агрегатов (суммы продаж и прибыли) в **источнике** `stg.orders` |
| [Correct_agregator_priemnik.csv](./Correct_agregator_priemnik.csv) | Проверка корректности агрегатов (суммы продаж и прибыли) в **приёмнике** `dw.sales_fact` |
| [Kategory.csv](./Kategory.csv) | Проверка данных по категориям (`dw.product_dim`) — распределение продуктов по категориям |
| [Kolvo_zakazov.csv](./Kolvo%20zakazov.csv) | Проверка количества заказов по сегментам (`stg.orders`) |
| [Kolvo_zapisei.csv](./Kolvo%20zapisei.csv) | Сравнение количества записей между источником и приёмником |
| [Negative_Quantity.csv](./Negative%20Quantity.csv) | Проверка на наличие отрицательных значений количества (`quantity < 0`) |
| [Negative_sales.csv](./Negative_sales.csv) | Проверка на наличие отрицательных значений продаж (`sales < 0`) |
| [Sum_discount.csv](./Sum_discount.csv) | Сравнение суммарных скидок между источником и приёмником |
| [Sum_profit.csv](./Sum_profit.csv) | Сравнение суммарной прибыли между источником и приёмником |
| [Sum_sales.csv](./Sum_sales.csv) | Сравнение суммарных продаж между источником и приёмником |
| [Tselostnost_date.csv](./Tselostnost_date.csv) | Проверка ссылочной целостности по дате — наличие записей в `dw.calendar_dim` |
| [Tselostnost_klient.csv](./Tselostnost_klient.csv) | Проверка ссылочной целостности клиентов (`dw.customer_dim`) |
| [Tselostnost_product.csv](./Tselostnost_product.csv) | Проверка ссылочной целостности продуктов (`dw.product_dim`) |
| [dubl_product.csv](./dubl_product.csv) | Проверка на наличие дубликатов по продуктам (`product_id`) |
| [quantity_sum.csv](./quantity_sum.csv) | Проверка общего количества единиц товара между источником и приёмником |
| [segments.csv](./segments.csv) | Проверка данных по сегментам заказов |
| [Sum_discont.csv](./Sum_discont.csv) | Проверка корректности сумм скидок (агрегаты) |

---
