USE pizzarunner;

SELECT * FROM new_customer_orders;
SELECT * FROM new_runner_orders;

-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS total_pizzas
FROM new_customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM new_customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS no_orders 
FROM new_runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT DISTINCT p.pizza_name, COUNT(c.pizza_id) AS no_orders 
FROM pizza_names AS p
INNER JOIN new_customer_orders AS c
	ON p.pizza_id = c.pizza_id
GROUP BY 1;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT DISTINCT c.customer_id, p.pizza_name, COUNT(c.order_id) AS no_orders 
FROM new_customer_orders AS c
INNER JOIN pizza_names AS p
	ON c.pizza_id = p.pizza_id
GROUP BY 1,2
ORDER BY 1 ASC;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT r.order_id, COUNT(c.pizza_id) AS pizzas_quantity
FROM new_runner_orders AS r
INNER JOIN new_customer_orders AS c
	ON r.order_id = c.order_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change, and how many had no changes?
SELECT
	c.customer_id,
    -- change means one of exclusions or extras has value
	SUM(CASE WHEN(c.exclusions IS NOT NULL OR c.extras IS NOT NULL) THEN 1 ELSE 0 END) AS orders_with_change,
    -- no change means no exclusions and no extras
    SUM(CASE WHEN(c.exclusions IS NULL AND c.extras IS NULL) THEN 1 ELSE 0 END) AS orders_without_change
FROM new_customer_orders AS c
INNER JOIN new_runner_orders AS r
	ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
    SUM(CASE WHEN(c.exclusions IS NOT NULL AND c.extras IS NOT NULL) THEN 1 ELSE 0 END) AS orders_with_both
FROM new_customer_orders AS c
INNER JOIN new_runner_orders AS r
	ON c.order_id = r.order_id
WHERE r.cancellation IS NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
EXTRACT(HOUR FROM order_time) AS hours, COUNT(pizza_id)
FROM new_customer_orders
GROUP BY 1
ORDER BY 1;

-- 10. What was the volume of orders for each day of the week?
SELECT 
DAYNAME(order_date) as Weekday, COUNT(order_id) AS volume_orders
FROM new_customer_orders
GROUP BY 1
ORDER BY 2 DESC;
