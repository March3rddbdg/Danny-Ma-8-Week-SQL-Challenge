USE pizza_runner;

/*

DANNY MA 8 WEEK SQL CHALLENGE 

WEEK 2: PIZZA RUNNER

PRICING AND RATINGS

*/

-- 1. If Meatlovers costs $12 and Vegetarian costs $10 and there were no charges for changes -- how much money has pizza runner made so far if there are no delivery fees?
SELECT *
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL;

-- create temp table with pizza id, pizza name, and price
DROP TABLE IF EXISTS pizza_price;
CREATE TEMPORARY TABLE pizza_price(
pizza_id VARCHAR(1),
pizza_name VARCHAR(25),
pizza_price INT);

INSERT INTO pizza_price
SELECT 
  pizza_id,
  pizza_name,
    CASE
		WHEN pizza_name = 'Meatlovers' THEN 12
        WHEN pizza_name = 'Vegetarian' THEN 10
        ELSE NULL END AS pizza_price
FROM pizza_names;

SELECT *
FROM pizza_price;

-- now join new price table to customer orders and runner orders
SELECT
	co.order_id,
    co.pizza_id,
    pp.pizza_name,
    pp.pizza_price
FROM customer_orders AS co
	INNER JOIN pizza_price AS pp
		ON co.pizza_id = pp.pizza_id
	INNER JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
ORDER BY 1;

-- make this CTE and pull sum of pizza price
WITH CTE_price AS
(SELECT
	co.order_id,
    co.pizza_id,
    pp.pizza_name,
    pp.pizza_price
FROM customer_orders AS co
	INNER JOIN pizza_price AS pp
		ON co.pizza_id = pp.pizza_id
	INNER JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
ORDER BY 1)

SELECT 
	SUM(pizza_price) AS total_revenue
FROM CTE_price;

-- Pizza Runner has earned $138 from the pizzas they've delivered.


-- 2. What if there were a $1 charge for any pizza extras?
SELECT *
FROM customer_orders;

-- case statement & make temp table
DROP TABLE IF EXISTS extra_price;
CREATE TEMPORARY TABLE extra_price (
order_id VARCHAR(2),
pizza_id VARCHAR(1),
extras varchar(10),
extra_price INT);

INSERT INTO extra_price (
SELECT 
	co.order_id,
    co.pizza_id,
    co.extras,
    CASE 
		WHEN co.extras LIKE '%,%' THEN 2
        WHEN co.extras = '1' THEN 1
        ELSE 0 END AS extra_price
FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL);

SELECT *
FROM extra_price;

-- join extra_price, pizza price
SELECT 
	ep.order_id,
    ep.pizza_id,
    pp.pizza_name,
    pp.pizza_price,
    ep.extra_price
FROM extra_price AS ep
	INNER JOIN pizza_price AS pp
		ON ep.pizza_id = pp.pizza_id;
        
-- make cte and query for sum
WITH CTE_extra_price AS 
(SELECT 
	ep.order_id,
    ep.pizza_id,
    pp.pizza_name,
    pp.pizza_price,
    ep.extra_price
FROM extra_price AS ep
	INNER JOIN pizza_price AS pp
		ON ep.pizza_id = pp.pizza_id)
        
SELECT 
	SUM(pizza_price) + SUM(extra_price) AS total_revenue
FROM CTE_extra_price;

-- The total revenue of delivered pizzas if Pizza Runner charged for extras would be $142
-- This is in contrast to the $138 revenue if they didn't charge for extras. 


-- 3. The pizza runner team now wants to add an additional ratings system that allows customers to rate their runner.
--    How would you design an additional table for this new dataset?
--    Genereate a schema for this new table and insert your own data for ratings for each susccessful customer order between 1-5.

-- ratings table should include customer id, runner id, rating, will also need order id
DROP TABLE IF EXISTS runner_ratings;
CREATE TEMPORARY TABLE runner_ratings (
runner_id VARCHAR(2),
customer_id VARCHAR(10),
order_id VARCHAR(5)
);

INSERT INTO runner_ratings (
SELECT 
	ro.runner_id,
	co.customer_id,
    co.order_id
FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
);

SELECT *
FROM runner_ratings
ORDER BY 1;

-- now add a column for rating

ALTER TABLE runner_ratings
ADD COLUMN rating int;

-- view runner orders table to generate rating
SELECT *
FROM runner_orders
	INNER JOIN customer_orders 
		ON runner_orders.order_id = customer_orders.order_id
WHERE runner_orders.cancellation IS NULL;
-- runner 1, order 1 took 32 minutes, we'll say 3
-- runner 1, order 2 took 27 minutes, we'll say 4
-- runner 1, order 3 took 20 minutes late at night for 2 zas, lets say 5
-- runer 1, order 10 took 10 minutes, lets say 5
-- runner 2 order 4 took 40 minutes for 3 pizzas in mid afternoon let's say 1
-- runner 2 order 7 25 minutes 1 pizza lets say 4
-- runner 2 order 8 15 minutes 1 pizza late at night let's say 5
-- runner 3 order 5 15 minutes 1 pizza only 10 miles away 9 pm lets say 4

UPDATE runner_ratings
SET rating = 3 WHERE order_id = 1;

UPDATE runner_ratings
SET rating = 5 WHERE order_id = 10;

UPDATE runner_ratings
SET rating = 5 WHERE order_id = 3;

UPDATE runner_ratings
SET rating = 4 WHERE order_id = 2;

UPDATE runner_ratings
SET rating = 1 WHERE order_id = 4;

UPDATE runner_ratings
SET rating = 4 WHERE order_id = 7;

UPDATE runner_ratings
SET rating = 5 WHERE order_id = 8;

UPDATE runner_ratings
SET rating = 4 WHERE order_id = 5;

SELECT *
FROM runner_ratings
ORDER BY runner_id;


-- 4. Using your newly generated table, can you join all info together to form table which has the following info for successful deliveries?
-- customer_id, order_id, runner_id, rating, order_time, pickup_time
SELECT
    co.order_id,
    co.customer_id,
    ro.runner_id,
    rr.rating,
    co.order_time,
    ro.pickup_time
FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
	INNER JOIN runner_ratings AS rr 
		ON ro.order_id = rr.order_id
GROUP BY 1,2,3,4,5,6;

-- add to info:
--  time between order and pickup, delivery duration, avg speed, total number of pizzas
WITH CTE_snapshot AS (
SELECT
    co.order_id,
    co.customer_id,
    ro.runner_id,
    rr.rating,
    co.order_time,
    ro.pickup_time, 
    TIMESTAMPDIFF(MINUTE, co.order_date_time, ro.pickup_date_time) AS order_to_pickup_minutes,
    ro.duration AS delivery_duration
FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
	INNER JOIN runner_ratings AS rr 
		ON ro.order_id = rr.order_id
GROUP BY 1,2,3,4,5,6,7,8)

SELECT
	CTE_snapshot.order_id,
    CTE_snapshot.customer_id,
    CTE_snapshot.runner_id,
    CTE_snapshot.rating,
    CTE_snapshot.order_time,
    CTE_snapshot.pickup_time,
    CTE_snapshot.order_to_pickup_minutes,
    CTE_snapshot.delivery_duration,
    ro.distance,
    (ro.distance/(CTE_snapshot.delivery_duration/60)) AS avg_speed,
    COUNT(co.order_id) AS pizzas_ordered
FROM CTE_snapshot
	INNER JOIN customer_orders AS co
		ON CTE_snapshot.order_id = co.order_id
	INNER JOIN runner_orders AS ro
		ON CTE_snapshot.order_id = ro.order_id
GROUP BY 1,2,3,4,5,6,7,8,9;

-- 5. If a Meatlovers pizza was $12 and a Vegetarian pizza was $10 fixed prices, no costs for extras, and there was a delivery fee of $0.30 per km -- how much money does Pizza Runner have leftover after deliveries?

-- First get runner pay, but need to use distinct order_id, because runners are only getting that pay for each order
-- The way the table is set up, the order_id is listed multiple times if there are different pizzas ordered within that one order
DROP TABLE IF EXISTS runner_fee;
CREATE TEMPORARY TABLE runner_fee (
order_id VARCHAR(5),
runner_id VARCHAR(2),
runner_fee DOUBLE);
INSERT INTO runner_fee 
SELECT 
	DISTINCT co.order_id,
    ro.runner_id,
    (ro.distance*.30) AS runner_fee
FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;
SELECT *
FROM runner_fee;
SELECT
	ROUND(SUM(runner_fee),2) AS total_runner_fees
FROM runner_fee;

-- Now I need the sum of each order, including all pizzas within that order.
-- Pull this into temp table
DROP TABLE IF EXISTS p_price;
CREATE TEMPORARY TABLE p_price (
order_id VARCHAR(5),
total INT);
INSERT INTO p_price    
WITH cte_pricing AS (        
 SELECT 
	co.order_id,
    co.pizza_id,
    pp.pizza_price,
    SUM(pp.pizza_price) OVER (PARTITION BY co.order_id) AS total
FROM customer_orders AS co
	INNER JOIN pizza_price AS pp
		ON co.pizza_id = pp.pizza_id
	INNER JOIN runner_orders AS ro
		ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL)
        
SELECT 
	order_id,
    total
FROM CTE_pricing
GROUP BY 1,2;

SELECT *
FROM p_price;

-- Now, I can join bth temp tables in a CTE and query the sums off of them to get the totals for revenue before fees, total fees and total revenue after fees
WITH cte_pricing AS
(SELECT	
	p.order_id,
    p.total,
    r.runner_fee,
    p.total - r.runner_fee AS total_after_fee
FROM p_price AS p
	INNER JOIN runner_fee AS r
		ON p.order_id = r.order_id)

SELECT 
	SUM(total) AS total_rev,
    ROUND(SUM(runner_fee),2) AS total_fees,
    SUM(total_after_fee) AS total_after_fees
FROM cte_pricing;

-- $94.80 is total revenue for Pizza Runner after runner fees








    

