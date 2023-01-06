USE dannydiner;

SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT DISTINCT s.customer_id, SUM(m.price) AS total
FROM sales AS s
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
GROUP BY 1;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited
FROM sales 
GROUP BY 1;

-- 3. What was the first item from the menu purchased by each customer?
WITH cte_order AS (
	SELECT s.customer_id AS customer_id, s.order_date, m.product_name AS first_order, 
		ROW_NUMBER() OVER (
			PARTITION BY s.customer_id
            ORDER BY s.order_date, s.product_id
		) AS row_no
    FROM sales AS s 
		LEFT JOIN menu AS m
			ON s.product_id = m.product_id
)
SELECT customer_id, first_order
FROM cte_order
WHERE row_no = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(s.product_id) AS most_purchased
FROM sales AS s
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH cte_most_ordered AS (
	SELECT s.customer_id AS customer_id, 
    m.product_name AS product_name, 
    COUNT(m.product_id) AS order_count,
    DENSE_RANK() OVER (
		PARTITION BY s.customer_id ORDER BY COUNT(m.product_id) DESC
	) AS ranks
	FROM sales AS s
		LEFT JOIN menu AS m
			ON s.product_id = m.product_id
	GROUP BY customer_id, product_name
)
SELECT customer_id, product_name, order_count
FROM cte_most_ordered
WHERE ranks = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH cte_member_first AS (
	SELECT 
	s.customer_id AS customer_id, 
	s.product_id,
	s.order_date,
	mm.join_date,
	DENSE_RANK() OVER (
		PARTITION BY s.customer_id ORDER BY s.order_date 
	) AS ranks
	FROM sales AS s
		LEFT JOIN members AS mm
			ON s.customer_id = mm.customer_id
	WHERE s.order_date >= mm.join_date
)
SELECT customer_id, product_name, join_date, order_date
FROM cte_member_first AS cte
	LEFT JOIN menu AS mn
		ON cte.product_id = mn.product_id;

-- 7. Which item was purchased just before the customer became a member?
WITH cte_before_member AS (
	SELECT 
	s.customer_id AS customer_id, 
	s.product_id,
	s.order_date,
	mm.join_date,
	DENSE_RANK() OVER (
		PARTITION BY s.customer_id ORDER BY s.order_date DESC
	) AS ranks
	FROM sales AS s
		LEFT JOIN members AS mm
			ON s.customer_id = mm.customer_id
	WHERE s.order_date < mm.join_date
)
SELECT customer_id, product_name, join_date, order_date
FROM cte_before_member AS cte
	LEFT JOIN menu AS mn
		ON cte.product_id = mn.product_id
WHERE ranks = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH cte_total_items_and_amount_spent AS (
	SELECT 
	s.customer_id AS customer_id, 
	s.product_id,
    COUNT(s.product_id) AS total_items,
    SUM(mn.price) AS amount_spent,
	DENSE_RANK() OVER (
		PARTITION BY s.customer_id ORDER BY s.order_date DESC
	) AS ranks
	FROM sales AS s
		LEFT JOIN members AS mm
			ON s.customer_id = mm.customer_id
		LEFT JOIN menu AS mn
			ON s.product_id = mn.product_id
	WHERE s.order_date < mm.join_date
	GROUP BY s.customer_id
)
SELECT DISTINCT customer_id, total_items, amount_spent
FROM cte_total_items_and_amount_spent AS cte
	LEFT JOIN menu AS mn
		ON cte.product_id = mn.product_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
	-- Assuming that the this applies to everyone, not only members
WITH cte_points AS (
	SELECT 
	s.customer_id AS customer, 
	CASE 
		WHEN m.product_name = 'sushi' THEN m.price * 20
		ELSE m.price * 10
	END AS points
FROM sales AS s
	LEFT JOIN menu AS m
		ON s.product_id = m.product_id
)
SELECT 
p.customer,
SUM(p.points) AS total_points
FROM cte_points AS p
GROUP BY 1;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
WITH cte_points AS ( 
	SELECT 
	s.customer_id AS customer,
	SUM(
		CASE 
			WHEN s.order_date < mm.join_date THEN							
				CASE 				-- non-member
					WHEN mn.product_name = 'sushi' THEN mn.price * 20
					ELSE mn.price * 10
				END
			WHEN s.order_date > (mm.join_date + 6) THEN 
				CASE 				-- regular member
					WHEN mn.product_name = 'sushi' THEN mn.price * 20
					ELSE mn.price * 10
				END
			ELSE (mn.price * 20) 			-- first week
		END
	) AS points
	FROM members AS mm
		LEFT JOIN sales AS s
			ON mm.customer_id = s.customer_id
		LEFT JOIN menu AS mn
			ON s.product_id = mn.product_id
	WHERE s.order_date <= '2021-01-31'
    GROUP BY 1
)
SELECT * 
FROM cte_points
ORDER BY customer;
            
    
