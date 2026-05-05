-- =========================
-- Задание 1: Работа с DML
-- =========================

-- Вставить два новых продукта
INSERT INTO products (
    product_id,
    product_name,
    price,
    category_id,
    product_class,
    modify_timestamp,
    resistant,
    is_allergic,
    vitality_days
)
VALUES 
    (506, 'test',   10,  1, 'A', NOW(), TRUE,  TRUE,  10),
    (507, 'test_2', 100, 2, 'B', NOW(), TRUE,  FALSE, 15);


-- Проверка
SELECT *
FROM products
ORDER BY modify_timestamp DESC;


-- Выбрать продукты, где is_allergic и resistant = 'Yes'
SELECT *
FROM products
WHERE is_allergic = TRUE
  AND resistant   = TRUE;


-- Обновить is_allergic для "Bananas Family Pack"
UPDATE products
SET is_allergic = TRUE
WHERE product_name = 'Bananas Family Pack';


-- Проверка
SELECT *
FROM products
WHERE product_name = 'Bananas Family Pack';


-- Удалить один из добавленных продуктов
DELETE FROM products
WHERE product_id = 507;


-- Проверка
SELECT *
FROM products
ORDER BY modify_timestamp DESC;



-- =========================
-- Задание 2: Работа с DDL
-- =========================

-- Создать таблицу Data_Layers
CREATE TABLE Data_Layers (
    LayerID SERIAL PRIMARY KEY,
    LayerName VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT
);


-- Заполнить LayerName
INSERT INTO Data_Layers (LayerName)
VALUES 
    ('Bronze'),
    ('Silver'),
    ('Gold');


-- Добавить колонку manager_email
ALTER TABLE shops
ADD COLUMN manager_email VARCHAR(100);


-- Заполнить колонку уникальными значениями
UPDATE shops
SET manager_email = CONCAT('manager_', shop_id, '@example.com');


-- Добавить UNIQUE constraint
ALTER TABLE shops
ADD CONSTRAINT unique_manager_email UNIQUE (manager_email);


-- Переименовать колонку address → shop_address
ALTER TABLE shops
RENAME COLUMN address TO shop_address;


-- Проверка
SELECT * FROM Data_Layers;
SELECT * FROM shops;



-- =========================
-- Задание 3: DCL
-- =========================

CREATE ROLE data_engineer_trainee
WITH LOGIN
PASSWORD '12345';


GRANT SELECT ON TABLE sales TO data_engineer_trainee;



-- =========================
-- Задание 4: DML / DCL
-- =========================

-- Увеличить цену продуктов категории
UPDATE products p
SET price = price * 1.1
FROM categories c
WHERE p.category_id = c.category_id
  AND c.category_name = 'Plant-Based Dairy';


-- Удалить сотрудников без продаж
DELETE FROM employees
WHERE employee_id NOT IN (
    SELECT DISTINCT employee_id
    FROM sales
);


-- Вставить нового сотрудника и продажу в одной транзакции
BEGIN;

INSERT INTO employees (
    employee_id,
    first_name,
    middle_initial,
    last_name,
    birth_date,
    gender,
    city_id,
    shop_id,
    hire_date
)
VALUES (
    321, 'Henry_test', 'N', 'Williams_test',
    '1990-09-24', 'M', 10, 47, '2023-07-08'
);

INSERT INTO sales (
    sales_id,
    employee_id,
    customer_id,
    product_id,
    quantity,
    discount,
    total_price,
    sales_timestamp,
    transaction_number
)
VALUES (
    2000001, 321, 76435, 153,
    4, 0.08, 108.76,
    '2022-09-23 02:05:10',
    'T0002000000'
);

COMMIT;



-- =========================
-- Задание 5: Функции и Представления
-- =========================

-- Функция: средняя сумма продаж сотрудника
CREATE OR REPLACE FUNCTION AvgSalesPerEmployee(p_employee_id INT)
RETURNS NUMERIC AS
$$
DECLARE
    avg_sales NUMERIC;
BEGIN
    SELECT AVG(total_price)
    INTO avg_sales
    FROM sales
    WHERE employee_id = p_employee_id;

    RETURN avg_sales;
END;
$$
LANGUAGE plpgsql;


-- Проверка функции
SELECT AvgSalesPerEmployee(321);


-- Представление: статистика по магазинам
CREATE VIEW FullStatShops AS
SELECT 
    sh.shop_id,
    sh.shop_address,
    ct.country_name AS country,
    COUNT(s.total_price) AS total_sales_count,
    COALESCE(SUM(s.total_price), 0) AS total_sales_amount
FROM sales s
JOIN employees e USING (employee_id)
RIGHT JOIN shops sh USING (shop_id)
JOIN cities c ON c.city_id = sh.city_id
JOIN countries ct USING (country_id)
GROUP BY 
    sh.shop_id,
    sh.shop_address,
    ct.country_name;


-- Проверка представления
SELECT * FROM FullStatShops;



-- =========================
-- Задание 6: DML
-- =========================

-- Найти сотрудников с продажами > 1000
SELECT 
    e.employee_id,
    e.last_name,
    e.first_name
FROM sales s
JOIN employees e USING (employee_id)
GROUP BY 
    e.employee_id,
    e.last_name,
    e.first_name
HAVING SUM(total_price) > 1000;


-- Обновить класс продуктов на 'A'
UPDATE products p
SET product_class = 'A'
FROM (
    SELECT category_id
    FROM sales s
    JOIN products p USING (product_id)
    GROUP BY category_id
    HAVING SUM(total_price) > 5000
) res
WHERE p.category_id = res.category_id;


-- Установить modify_timestamp для NULL
UPDATE products
SET modify_timestamp = NOW()
WHERE modify_timestamp IS NULL;