
-- countries 
COPY countries(country_id, country_name, country_code)
FROM '/Users/anna/BigData_lab/source/countries.csv'
DELIMITER ';'
CSV HEADER;

-- cities 
COPY cities(city_id, city_name, zipcode, country_id)
FROM '/Users/anna/BigData_lab/source/cities.csv'
DELIMITER ';'
CSV HEADER;

-- categories 
COPY categories(category_id, category_name)
FROM '/Users/anna/BigData_lab/source/categories.csv'
DELIMITER ';'
CSV HEADER;

-- shops 
COPY shops(shop_id, city_id, address)
FROM '/Users/anna/BigData_lab/source/shops.csv'
DELIMITER ';'
CSV HEADER;

-- products 
COPY products(
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
FROM '/Users/anna/BigData_lab/source/products.csv'
DELIMITER ';'
CSV HEADER;

-- employees
COPY employees_row(
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
FROM '/Users/anna/BigData_lab/source/employees.csv'
DELIMITER ';'
CSV HEADER;

INSERT INTO public.employees
	SELECT 	employee_id,
			first_name,
			middle_initial,
			last_name,
			safe_to_date(birth_date), 
			gender, 
			city_id,
			shop_id, 
			safe_to_date(hire_date)
	FROM public.employees_row;

-- customers 
COPY customers(
    customer_id,
    first_name,
    middle_initial,
    last_name,
    city_id,
    address
)
FROM '/Users/anna/BigData_lab/source/customers.csv'
DELIMITER ';'
CSV HEADER;


--sales
COPY sales(
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
FROM '/Users/anna/BigData_lab/source/sales.csv'
DELIMITER ';'
CSV HEADER;