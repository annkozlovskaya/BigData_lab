-- Задача 1.1 
-- Вывести для каждой продажи название продукта, его категорию и магазин  

SELECT 
    s.sales_id, 
    p.product_name, 
    c.category_name, 
    sh.address  
FROM sales s
JOIN products p USING (product_id)
JOIN categories c USING (category_id)
JOIN employees e USING (employee_id)
JOIN shops sh USING (shop_id);


-- Задача 2.1 
-- Вывести все магазины расположенные в 'Poland'.
-- Необходимые колонки: shop_id, address, city_name, country.

SELECT 
    shop_id, 
    address, 
    city_name, 
    c.country_name AS country
FROM shops sh
JOIN cities ct USING (city_id)
JOIN countries c USING (country_id)
WHERE c.country_name = 'Poland';


-- Задача 2.2
-- Вывести все транзакции с суммой продажи выше 1500 (total_price > 1500) 
-- для продуктов класса B (class = 'B'), 
-- выполнить сортировку по номеру транзакции.

SELECT 
    transaction_number, 
    p.product_name, 
    total_price, 
    customer_id, 
    sales_timestamp 
FROM sales s
JOIN products p USING (product_id)
WHERE p.product_class = 'B' 
  AND s.total_price > 1500
ORDER BY 1;


-- Задача 3.1
-- Вывести количество магазинов (Shops) в каждой стране 
-- и отсортировать по количеству магазинов по убыванию.

SELECT 
    c.country_name, 
    COUNT(sh.city_id)
FROM shops sh
JOIN cities ct USING (city_id)
JOIN countries c USING (country_id)
GROUP BY c.country_name
ORDER BY 2 DESC;


-- Задача 4.1
-- Вывести по каждому продукту сумму продаж и средний чек,
-- где сумма продаж выше 400,000.00 . 
-- Так же отсортируйте вывод по сумме продаж по убыванию. 

SELECT 
    p.product_name,  
    SUM(total_price) AS total_revenue, 
    AVG(total_price) AS avg_sale
FROM sales s
JOIN products p USING (product_id)
GROUP BY p.product_name
HAVING SUM(total_price) > 400000
ORDER BY 2 DESC;


-- Задача 5.1
-- Вывести Имя и Фамилию продавца, который совершил продажу 
-- с максимальной суммой и вывести адрес магазина, в котором он работает.

SELECT  
    e.first_name, 
    e.last_name, 
    sh.address, 
    total_price AS max_amount
FROM sales s
JOIN employees e USING (employee_id)
JOIN shops sh USING (shop_id)
WHERE total_price = (
    SELECT MAX(total_price)
    FROM sales
);


-- Задача 6.1
-- Найти выручку всех магазинов в Германии по месяцам 
-- и разницу с предыдущим месяцем. Применить сортировку по месяцам по возрастанию.

SELECT 
    date_trunc('month', s.sales_timestamp) AS sale_month,
    SUM(total_price) AS monthly_revenue,
    COALESCE(
        LAG(SUM(total_price)) OVER (
            ORDER BY date_trunc('month', s.sales_timestamp)
        ), 
        0
    ) AS previous_month_revenue,
    SUM(total_price) - COALESCE(
        LAG(SUM(total_price)) OVER (
            ORDER BY date_trunc('month', s.sales_timestamp)
        ), 
        0
    ) AS revenue_diff_vs_previous
FROM sales s
JOIN employees e USING (employee_id)
JOIN shops sh USING (shop_id)
JOIN cities ct ON sh.city_id = ct.city_id
JOIN countries c USING (country_id)
WHERE c.country_name = 'Germany' 
  AND s.sales_timestamp IS NOT NULL
GROUP BY date_trunc('month', s.sales_timestamp);


-- Задача 7
--Для каждого магазина рассчитать агрегаты продаж и аналитические показатели в разрезе страны.

--количество продаж (COUNT(sales_id))
--общую сумму продаж (SUM(total_price))
--Оставить только магазины, у которых не менее 2 продаж.

--Для каждого такого магазина рассчитать:

--долю оборота магазина от общего оборота страны
--ранг магазина по сумме продаж внутри своей страны
--накопительный оборот по стране,
--отсортированный по убыванию оборота магазина
--Отсортировать результат:
-- по стране
-- по рангу магазина

SELECT 
    country_name, 
    shop_id, 
    address, 
    total_sales_count, 
    total_sales_amount,  
    country_total,  
    total_sales_amount / country_total AS country_sales_share, 

    RANK() OVER (
        PARTITION BY country_name 
        ORDER BY total_sales_amount DESC
    ) AS shop_rank,

    SUM(total_sales_amount) OVER (
        PARTITION BY country_name 
        ORDER BY total_sales_amount DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )

FROM (
    SELECT DISTINCT 
        c.country_name, 
        e.shop_id, 
        sh.address, 

        COUNT(sales_id) OVER (
            PARTITION BY e.shop_id
        ) AS total_sales_count, 

        SUM(total_price) OVER (
            PARTITION BY e.shop_id
        ) AS total_sales_amount,

        SUM(total_price) OVER (
            PARTITION BY c.country_name
        ) AS country_total

    FROM sales
    JOIN employees e USING (employee_id)
    JOIN shops sh USING (shop_id)
    JOIN cities ct ON sh.city_id = ct.city_id
    JOIN countries c USING (country_id)

) t
WHERE total_sales_count > 2
ORDER BY 
    1, 
    shop_rank;
