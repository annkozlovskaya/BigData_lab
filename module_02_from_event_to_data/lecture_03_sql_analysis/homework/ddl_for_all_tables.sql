-- countries 
CREATE TABLE countries (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(100),
    country_code VARCHAR(10)
);

-- cities 
CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100),
    zipcode VARCHAR(20),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

-- categories
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

-- products 
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    category_id INT,
    product_class VARCHAR(50),
    modify_timestamp TIMESTAMP,
    resistant BOOLEAN,
    is_allergic BOOLEAN,
    vitality_days INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- shops 
CREATE TABLE shops (
    shop_id INT PRIMARY KEY,
    city_id INT,
    address VARCHAR(255),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

-- employees_row 
CREATE TABLE employees_row (
    employee_id INT,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    birth_date VARCHAR(100),
    gender VARCHAR(10),
    city_id INT,
    shop_id INT,
    hire_date VARCHAR(100)
);

-- function to replace wrong date to null
CREATE OR REPLACE FUNCTION safe_to_date(value TEXT)
RETURNS DATE AS $$
BEGIN
    RETURN value::DATE;
EXCEPTION WHEN others THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(10),
    city_id INT,
    shop_id INT,
    hire_date DATE,
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id)
);


-- customers 
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    city_id INT,
    address VARCHAR(255),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

-- sales
CREATE TABLE sales (
    sales_id INT PRIMARY KEY,
	employee_id INT,
    customer_id INT,
	product_id INT,
	quantity INT,
	discount DECIMAL(10,2),
	total_price DECIMAL(10,2),
	sales_timestamp TIMESTAMP, 
    transaction_number CHAR(11), 
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);