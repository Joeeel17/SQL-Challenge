USE pizzarunner;

SELECT * FROM runners;

-- Data Exploration
SELECT DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE
TABLE_SCHEMA = 'pizzarunner' AND TABLE_NAME = 'runner_orders'; 

SELECT DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE
TABLE_SCHEMA = 'pizzarunner' AND TABLE_NAME = 'customer_orders'; 

SELECT * FROM runners;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;

SELECT * FROM customer_orders;
-- customer_orders 
	-- order_time combines date and time together.
	-- exclusions and extras has blanks and null. 
	-- note: 
        -- each order_id refers to a single pizza in the order
        -- exclusions refer to ingredient id values which should be removed
		-- while extras refer to ingredients that should be added

SELECT * FROM runner_orders;
-- runner_orders 
	-- pickup_time combines date and time together.
	-- distance and duration has messy data (data types are not fixed).
	-- pickup_time, distance and duration has null values. 
    -- cancellation has blanks and null. 

-- To Do
-- 1. Separate pickup_time and order_time per date and time with proper data type
-- 2. Set proper data type for distance and duration - INT
-- 3. Normalize all blank values to NULL

-- Data Cleaning

SELECT * FROM customer_orders;

DROP TEMPORARY TABLE IF EXISTS new_customer_orders;

CREATE TABLE new_customer_orders
SELECT 
	order_id,
    customer_id, 
    pizza_id,
    CASE
		WHEN exclusions LIKE 'null'
			OR exclusions LIKE 'NaN' 
			OR exclusions LIKE '' THEN NULL
		ELSE exclusions
	END AS exclusions,
    CASE
		WHEN extras LIKE 'null'
			OR extras LIKE 'NaN' 
			OR extras LIKE '' THEN NULL
		ELSE extras
	END AS extras,
    DATE(order_time) AS order_date,
    DATETIME(TIME_FORMAT((order_time), "%H:%i:%s")) AS order_time
FROM customer_orders;

SELECT * FROM new_customer_orders;


DROP TEMPORARY TABLE IF EXISTS new_runner_orders;
CREATE TABLE new_runner_orders
SELECT 
	order_id,
    runner_id, 
    CASE 
		WHEN pickup_time LIKE 'null'
			THEN NULL
		ELSE DATE(pickup_time)
	END AS pickup_date,
    CASE 
		WHEN pickup_time LIKE 'null'
			THEN NULL
		ELSE TIME_FORMAT((pickup_time), "%H:%i:%s")
	END AS pickup_time,
    CASE 
		WHEN distance LIKE '%km' 
			THEN TRIM('km' FROM distance)
		WHEN distance LIKE 'null'
			THEN NULL 
		ELSE distance
	END AS distance_in_km,
    CASE 
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
		WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
		WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
		WHEN duration LIKE 'null'
			THEN NULL 
	END AS duration_in_mins,
    CASE
		WHEN cancellation LIKE 'null'
			OR cancellation LIKE 'NaN' 
			OR cancellation LIKE '' THEN NULL
		ELSE cancellation
	END AS cancellation
FROM runner_orders;

SELECT * FROM new_runner_orders;

-- Time Columns with TIME types
DROP TABLE IF EXISTS new_customer_orders_test;
CREATE TABLE new_customer_orders_test
SELECT 
	order_id,
    customer_id, 
    pizza_id,
    CASE
		WHEN exclusions LIKE 'null'
			OR exclusions LIKE 'NaN' 
			OR exclusions LIKE '' THEN NULL
		ELSE exclusions
	END AS exclusions,
    CASE
		WHEN extras LIKE 'null'
			OR extras LIKE 'NaN' 
			OR extras LIKE '' THEN NULL
		ELSE extras
	END AS extras,
    DATE(order_time) AS order_date,
    CAST(TIME_FORMAT((order_time), "%H:%i:%s") AS TIME) AS order_time
FROM customer_orders;
SELECT * FROM new_customer_orders_test;

DROP TABLE IF EXISTS new_runner_orders_test;
CREATE TABLE new_runner_orders_test
SELECT 
	order_id,
    runner_id, 
    CASE 
		WHEN pickup_time LIKE 'null'
			THEN NULL
		ELSE DATE(pickup_time)
	END AS pickup_date,
    CASE 
		WHEN pickup_time LIKE 'null'
			THEN NULL
		ELSE CAST(TIME_FORMAT((pickup_time), "%H:%i:%s") AS TIME)
	END AS pickup_time,
    CASE 
		WHEN distance LIKE '%km' 
			THEN TRIM('km' FROM distance)
		WHEN distance LIKE 'null'
			THEN NULL 
		ELSE distance
	END AS distance_in_km,
    CASE 
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
		WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
		WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
		WHEN duration LIKE 'null'
			THEN NULL 
	END AS duration_in_mins,
    CASE
		WHEN cancellation LIKE 'null'
			OR cancellation LIKE 'NaN' 
			OR cancellation LIKE '' THEN NULL
		ELSE cancellation
	END AS cancellation
FROM runner_orders;