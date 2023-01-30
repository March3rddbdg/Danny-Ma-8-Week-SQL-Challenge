/* 

DANNY MA SQL CHALLENGE WEEK 1: "DANNY'S DINER"

*/

-- Create database and tables

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
SELECT * 
FROM sales;
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

SELECT *
FROM menu;  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  SELECT *
  FROM members;

-- sales table customer_id is primary key for this table, and foreign key as well - also primary key for members table
-- sales table product_id is foreign key -- primary key of menu table
-- sales table shows customer id, date of purchase, and product ordered
-- members table shows customer_id and date that customer became member
-- menu table shows product_id, product name, and price
  
/*

CASE STUDY QUESTIONS 

*/

-- 1.. What is total amount each customer spent at restaurant?
SELECT *
FROM sales;

SELECT 
	sales.customer_id,
    SUM(menu.price) AS amount_spent
FROM 
	sales 
    INNER JOIN menu
		ON sales.product_id = menu.product_id
GROUP BY 1;


-- 2. How many days has each customer visited the restaurant?
SELECT 
	customer_id,
    COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY 1;


-- 3. What was the first item from the menu purchased by each customer?

-- need the min date group by customer, join menu table and select product id and name 
-- need to rank by date partitioning on each customer and then use cte to query to find first date
-- use dense_rank because multiple items purchased in one day, and want the ranking to be continuous (regular rank will skip rank 2 if there are 2 1s)
SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name,
    DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rank_date
FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id;
        
-- Now make cte
WITH CTE_rank AS
(SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name,
    DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rank_date
FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id
)
SELECT 
	customer_id,
    product_name
FROM CTE_rank
WHERE rank_date = 1
GROUP BY 1,2;


-- 4. What is the most purchased item on the menu, and how many times was it purchased by all customers?

-- First get count of each product purchased from sales table
SELECT 
	product_id,
	COUNT(product_id) AS times_purchased
FROM sales
GROUP BY 1;

-- join on menu table to get name of product, order descending by count
SELECT 
	COUNT(sales.product_id) AS times_purchased,
    menu.product_name
FROM sales
	INNER JOIN menu
		ON sales.product_id = menu.product_id
GROUP BY 
	sales.product_id, menu.product_name
ORDER BY 1 DESC;

-- limit 1 to get top 1
SELECT 
	COUNT(sales.product_id) AS times_purchased,
    menu.product_name
FROM sales
	INNER JOIN menu
		ON sales.product_id = menu.product_id
GROUP BY 
	sales.product_id, menu.product_name
ORDER BY 1 DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?

-- look at sales
SELECT *
FROM sales;

-- count of each product id, grouped by customer and product id
SELECT
	sales.customer_id,
    sales.product_id,
    COUNT(sales.product_id) AS times_purchased,
    menu.product_name
FROM sales
	INNER JOIN menu
		ON sales.product_id = menu.product_id
GROUP BY 1,2,4;

-- now use rank and partition by functions
SELECT 
	sales.customer_id,
	menu.product_name,
    COUNT(*) AS order_count,
    DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(sales.customer_id) DESC) AS qty_rank
FROM sales
	INNER JOIN menu
		ON sales.product_id = menu.product_id
GROUP BY 1,2;

-- now make cte and query to find rank 1s
WITH CTE_rank AS (
SELECT 
	sales.customer_id,
	menu.product_name,
    COUNT(*) AS order_count,
    DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(sales.customer_id) DESC) AS qty_rank
FROM sales
	INNER JOIN menu
		ON sales.product_id = menu.product_id
GROUP BY 1,2
)
SELECT 
	customer_id,
    product_name,
    order_count
FROM CTE_rank
WHERE qty_rank = 1;


-- 6. Which item was purchased first by each customer after they became a member?

-- I'm going to need to use CTE and rank, ranking the date in order by of OVER and partitioning by customer
-- first let's get the table, then I can make the cte and query to find first

SELECT *
FROM members;

-- Customer C is not even a member!
-- i'm going to join the sales and menu table on the product id, and the sales and members data on id

SELECT
	sales.customer_id,
    menu.product_name,
    sales.order_date,
    members.join_date,
    DENSE_RANK() OVER (PARTITION BY(sales.customer_id) ORDER BY sales.order_date) AS rank_orders
FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id
	INNER JOIN members
		ON sales.customer_id = members.customer_id 
WHERE sales.order_date >= members.join_date
GROUP BY 1,2,3,4;     

-- now, I can create my cte, and query off of it
WITH CTE_member_first_order AS
(SELECT
	sales.customer_id,
    menu.product_name,
    sales.order_date,
    members.join_date,
    DENSE_RANK() OVER (PARTITION BY(sales.customer_id) ORDER BY sales.order_date) AS rank_orders
FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id
	INNER JOIN members
		ON sales.customer_id = members.customer_id 
WHERE sales.order_date >= members.join_date)

SELECT
	customer_id, 
    order_date,
	product_name
FROM CTE_member_first_order
WHERE rank_orders = 1;


-- 7. Which item was purchased just before the customer became a member?

-- I'm going to use the above query that turned into the CTE and tweak it to where sales date is less than (before) join date, and order the partition by the order date DESC to flip it
SELECT
	sales.customer_id,
    menu.product_name,
    sales.order_date,
    members.join_date,
    DENSE_RANK() OVER (PARTITION BY(sales.customer_id) ORDER BY sales.order_date DESC) AS rank_orders
FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id
	INNER JOIN members
		ON sales.customer_id = members.customer_id 
WHERE sales.order_date < members.join_date
GROUP BY 1,2,3,4;   

-- now turn it into cte and query off of it
WITH CTE_before_member_purchase AS
(SELECT
	sales.customer_id,
    menu.product_name,
    sales.order_date,
    members.join_date,
    DENSE_RANK() OVER (PARTITION BY(sales.customer_id) ORDER BY sales.order_date DESC) AS rank_orders
FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id
	INNER JOIN members
		ON sales.customer_id = members.customer_id 
WHERE sales.order_date < members.join_date)

SELECT 
	customer_id,
    product_name,
    order_date
FROM CTE_before_member_purchase
WHERE rank_orders = 1;


-- 8. What is the total items and amount spent for each member before they became a member?

-- First. pull each customer, products purchased and price of those where order date is before member join date
SELECT 
	sales.customer_id,
    sales.order_date,
    sales.product_id,
    menu.price
FROM sales
	INNER JOIN menu	
		ON sales.product_id = menu.product_id
	INNER JOIN members
		ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date
GROUP BY 1,2,3,4;

-- Count the number of products ordered and sum the prices, grouping on customer id and again filtering before join date
SELECT 
	sales.customer_id,
    COUNT(sales.product_id) AS total_products,
    SUM(menu.price) AS total_spent
FROM sales
	INNER JOIN members
		ON sales.customer_id = members.customer_id
	INNER JOIN menu
		ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY 1;


-- 9. If each $1 spent equates to 10 points, and sushi has a 10x points multiplier, how many points would each customer have?

-- Equation for non-sushi is points = (dollars spent*10)
-- Equation for sushi is points = 2*(dollars spent*10) OR (dollars spent*20)

-- Find points per product
SELECT
	product_id,
    product_name,
    price,
    CASE
		WHEN product_id = 1 THEN (price*20)
        ELSE (price*10)
        END AS points
FROM menu
GROUP BY 1,2,3,4;

-- Now make above a cte and join on sales grouping on customer id to pull the sum of points per customer
WITH CTE_points2 AS
(SELECT
	product_id,
    product_name,
    price,
    CASE
		WHEN product_id = 1 THEN (price*20)
        ELSE (price*10)
        END AS points
FROM menu
GROUP BY 1,2,3,4)

SELECT
	sales.customer_id,
    SUM(CTE_points2.points) AS total_points
FROM sales
	INNER JOIN CTE_points2
		ON sales.product_id = CTE_points2.product_id
GROUP BY 1;
 

-- 10. In the first week after a customer joins the program (including their join date), they earn 2x points on ALL items.
--     How many points do customers A and B have by the end of January?

-- Offer is valid for a week including join date

-- join date + 6 days
SELECT
	customer_id,
    join_date AS first_offer_day,
    DATE_ADD(members.join_date, INTERVAL 6 DAY) AS last_offer_day
FROM 
	members
GROUP BY 1,2,3;

-- use this as cte and then query using case and joins
WITH CTE_promo AS
(SELECT
	customer_id,
    join_date AS first_offer_day,
    DATE_ADD(members.join_date, INTERVAL 6 DAY) AS last_offer_day
FROM 
	members
GROUP BY 1,2,3)

SELECT
	CTE_promo.customer_id,
    sales.order_date,
    CTE_promo.first_offer_day,
    CTE_promo.last_offer_day,
    menu.product_name,
    menu.price,
    SUM(CASE
			WHEN menu.product_name = 'sushi' THEN (menu.price*20)
            WHEN sales.order_date BETWEEN CTE_promo.first_offer_day AND CTE_promo.last_offer_day THEN (menu.price*20)
            ELSE (menu.price*10)
            END) AS points
FROM CTE_promo 
	INNER JOIN sales
		ON CTE_promo.customer_id = sales.customer_id
	JOIN menu
		ON sales.product_id = menu.product_id
WHERE sales.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY 1,2,3,4,5,6;

-- now make temp table with results to be able to get sum of points per customer
CREATE TEMPORARY TABLE promo_points (
customer_id VARCHAR(1),
order_date DATE,
first_offer_day DATE,
last_offer_day DATE,
product_name VARCHAR(5),
price INT,
points INT);

INSERT INTO promo_points
WITH CTE_promo AS
(SELECT
	customer_id,
    join_date AS first_offer_day,
    DATE_ADD(members.join_date, INTERVAL 6 DAY) AS last_offer_day
FROM 
	members
GROUP BY 1,2,3)

SELECT
	CTE_promo.customer_id,
    sales.order_date,
    CTE_promo.first_offer_day,
    CTE_promo.last_offer_day,
    menu.product_name,
    menu.price,
    SUM(CASE
			WHEN menu.product_name = 'sushi' THEN (menu.price*20)
            WHEN sales.order_date BETWEEN CTE_promo.first_offer_day AND CTE_promo.last_offer_day THEN (menu.price*20)
            ELSE (menu.price*10)
            END) AS points
FROM CTE_promo 
	INNER JOIN sales
		ON CTE_promo.customer_id = sales.customer_id
	JOIN menu
		ON sales.product_id = menu.product_id
WHERE sales.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY 1,2,3,4,5,6;

SELECT *
FROM promo_points;

SELECT
	customer_id,
	SUM(points) AS jan_points
FROM promo_points
GROUP BY 1;

    
 /* 
 
 BONUS QUESTIONS
 
 */
 
 -- 11. Recreate table output pictured using available data.
 
 -- The table has 5 columns: customer_id, order_date, product_name, price and a Y/N column for member based on order date
 
 -- Pull 4 of 5 columns from the 3 available tables directly. The Y/N column comes from join date compared to order date.
 -- Join all 3 tables and pull everything besides final column first
 -- Make sure to join members on left, to include all customer ids from sales table!
 SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price
FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id
	LEFT JOIN members
		ON sales.customer_id = members.customer_id;

-- That's everything without that final column. Now I'll add case statement for that column in select to recreate the table output
 SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    CASE
		WHEN sales.order_date < members.join_date THEN 'N'
        WHEN sales.order_date >= members.join_date THEN 'Y'
        ELSE 'N'
        END AS member
FROM sales
	LEFT JOIN menu 
		ON sales.product_id = menu.product_id
	LEFT JOIN members
		ON sales.customer_id = members.customer_id;


-- 12. Danny requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the reconrds when customers are not yet part of the loyalty program.

-- I can use the above statement and add rank, partioning by customer id and member and ordering by order date
-- But I also need to add null if member = N. Use above statement as CTE and query off of it to get rank
WITH CTE_ranking AS
(SELECT
	sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    CASE
		WHEN sales.order_date < members.join_date THEN 'N'
        WHEN sales.order_date >= members.join_date THEN 'Y'
        ELSE 'N'
        END AS member
FROM sales
	INNER JOIN menu 
		ON sales.product_id = menu.product_id
	LEFT JOIN members
		ON sales.customer_id = members.customer_id)

SELECT 
	*,
    CASE
		WHEN member = 'N' THEN 'null'
        ELSE DENSE_RANK() OVER (PARTITION BY customer_id,member ORDER BY order_date)
        END AS ranking
FROM CTE_ranking;

/*

INSIGHTS

*/

-- 1. Danny's Diner's busiest order day was 1/1/2021 - 5 New Year's Day orders.
-- 2. Customer A and Customer C ordered ramen the most, 3 orders each. Customer B seemed to like all 3 of Danny's offerings equally, ordering each product twice.
-- 3. Customer A and Customer B are both members of the program, nad have earned 1370 and 820 points respectively in January based on the promo Danny offered.
-- 4. Sushi is the least ordered item at Danny's Diner. The most ordered item is ramen.
-- 5. If Danny is looking to entice more customers into membership like Customer c, he might try running a point promotion on ramen, as it was the most popular item.


 
 
 
	

    