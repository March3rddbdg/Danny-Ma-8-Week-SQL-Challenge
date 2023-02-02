/*

DANNY MA 8 WEEK SQL CHALLENGE WEEK 2: PIZZA RUNNER

PIZZA METRICS

*/

USE pizza_runner;

-- 1. How many pizzas were ordered?
-- The customer orders table has a row for each pizza ordered, the order_id row. 
-- Just a count of this column
SELECT
	COUNT(order_id) AS pizzas_ordered
FROM customer_orders;

-- 14 pizzas ordered


-- 2. How many unique customer orders were made?
-- The number of unique orders.
SELECT 
	COUNT(DISTINCT order_id) as unique_customer_orders
FROM customer_orders;

-- There were 10 different orders placed. 

-- In contrast, the number of unique customers can be found.
SELECT
	COUNT(DISTINCT customer_id) AS unique_customers
FROM customer_orders;

-- There are 5 unique customers.


-- 3. How many successful orders were placed by each runner?

-- First look runner_orders tables.
SELECT *
FROM runner_orders;

-- Successful orders are where cancellation was null.
-- Distinct order_ids per runner
SELECT
	runner_id,
    COUNT(DISTINCT order_id) AS success_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY 1;

-- Runner 1: 4 orders delivered sucessfull
-- Runner 2: 3 orders
-- Runner 3: 1 order



-- 4. How many of each type of pizza was delivered?

-- join customer and runner orders tables making sure to filter out non-delivered or cancelled orders
-- count entries in pizza_id column broken up by pizza_id
SELECT
	customer_orders.pizza_id,
	COUNT(customer_orders.pizza_id) AS count_pizza
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY 1;

-- 9 of pizza 1 were delivered
-- 3 of pizza 2 were delivered


-- 5. How many of each Vegetarian and Meatlovers pizzas were ordered by each customer?

-- join customer orders and pizza names.
SELECT 
	customer_orders.customer_id,
    COUNT(pizza_names.pizza_name) AS qty_ordered,
    pizza_names.pizza_name
FROM customer_orders
	INNER JOIN pizza_names
		WHERE customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY 1,3
ORDER BY 1;

-- Customer 101: 2 meat, 1 veg
-- Customer 102: 2 meat, 1 veg
-- Customer 103: 3 meat, 1 veg
-- Customer 104: 3 meat
-- Customer 105: 1 veg


-- 6. What was maximum number of pizzas delivered in a single order?
SELECT *
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL;

-- need to pull number of pizzas per order id
SELECT 
	DISTINCT(customer_orders.order_id),
    COUNT(customer_orders.pizza_id) AS max_number_ordered
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;

-- Maximum pizzas delivered in single order was 3


-- 7. For each customer, how many delivered pizzas had at least one change, and how many had no changes?
SELECT *
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL;

-- group by customer id
-- count of pizza id where exclusions and extras were both null
-- count of piza id where exclusions or extras were not null
-- case statement
SELECT 
	customer_orders.order_id,
    CASE 
		WHEN exclusions OR extras IS NOT NULL THEN 'change'
        ELSE 'no change'
        END AS changes_made
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY 1,2;

-- now do a count of above
-- SELECT 
-- 	customer_orders.order_id,
--     COUNT(CASE 
-- 		WHEN exclusions OR extras IS NOT NULL THEN 'change'
--        ELSE 'no change'
--        END) AS qty_changes
-- FROM customer_orders
-- 	INNER JOIN runner_orders
-- 		ON customer_orders.order_id = runner_orders.order_id
-- WHERE runner_orders.cancellation IS NULL
-- GROUP BY 1
-- ORDER BY 1;

-- need to quantify case statement and set no change to 0, otherwise count is counting no change as a number

SELECT
	customer_orders.customer_id,
    CASE
		WHEN customer_orders.exclusions <> '' OR customer_orders.extras <> '' THEN 1
        ELSE 0
        END AS changes_made,
	CASE 
		WHEN customer_orders.exclusions IS NULL AND customer_orders.extras IS NULL THEN 1
        ELSE 0
        END AS no_changes_made
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY 1,2,3
ORDER BY 1;

-- now get sum of those cases to condense customer id down to 1 per customer id
SELECT
	customer_orders.customer_id,
    SUM(CASE
		WHEN customer_orders.exclusions <> '' OR customer_orders.extras <> '' THEN 1
        ELSE 0
        END) AS changes_made,
	SUM(CASE 
		WHEN customer_orders.exclusions IS NULL AND customer_orders.extras IS NULL THEN 1
        ELSE 0
        END) AS no_changes_made
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
GROUP BY 1
ORDER BY 1;

-- Customer 101 had 0 pizzas with changes, and 2 without changes
-- Customer 102 had 0 with changes, 3 without
-- Customer 103 had 3 with changes, 0 without
-- Customer 104 had 2 with changes, 1 without
-- Customer 105 had 1 with changes, 0 without


-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
	COUNT(customer_orders.order_id)
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL
	AND customer_orders.exclusions IS NOT NULL
    AND customer_orders.extras IS NOT NULL;

-- Only 1 pizza was delivered that had both exclusions and extras.
-- Looks like they had multiple of each - a picky eater!
-- Other than this one customer, it seems like additions or subtractions are more common than substitutions


-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
    substring(order_time,1,2) AS hour_ordered,
    COUNT(order_id) AS pizzas_ordered
FROM customer_orders
GROUP BY 1
ORDER BY 1;

-- 11 am and 7 pm were least popular with 1 each
-- 1 pm, 6 pm, 9 pm and 11 pm were most popular with 3 each. Lunch, dinner and late crowd love pizza

SELECT *
FROM customer_orders;
-- 10. What was the volume of orders for each day of the week?

-- count order ids 
-- convert the order date to a day of week and group order id count by this

SELECT 
	DAYNAME(order_date) AS day_of_week,
    COUNT(order_id) AS pizzas_ordered
FROM customer_orders
GROUP BY 1
ORDER BY 2 DESC;

-- Wednesday and Saturday had highest volume of pizzas ordered with 5 pizzas ordered each day.
-- Thursday had 3 pizzas ordered.
-- Friday had 1 pizza ordered. 
-- Friay is not a popular day for pizza; not many Friday Night Pizza celebrators out there! 
