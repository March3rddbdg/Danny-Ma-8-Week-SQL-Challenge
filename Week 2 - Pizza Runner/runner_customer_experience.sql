/*

DANNY MA 8 WEEK SQL CHALLENGE WEEK 2: PIZZA RUNNER

RUNNER AND CUSTOMER EXPERIENCE

*/

-- 1. How many runners signed up for each 1 week period? (week period starts 01-01-2020
SELECT *
FROM runners;

-- need to assign cases for each week period and count runner id's within each
SELECT
	CASE
		WHEN registration_date >= '2021-01-01' AND registration_date <= '2021-01-07' THEN 'Week 1'
        WHEN registration_date >= '2021-01-08' AND registration_date <= '2021-01-14' THEN 'Week 2'
        WHEN registration_date >= '2021-01-15' AND registration_date <= '2021-01-21' THEN 'Week 3'
        WHEN registration_date >= '2021-01-22' AND registration_date <= '2021-01-28' THEN 'Week 4'
        ELSE 'Week 5' END AS week_period,
	COUNT(runner_id) AS runners_signed_up
FROM runners
GROUP BY 1;

-- it looks like error possibly? Registration dates are in 2021, but order information is in 2020.
-- Week 1: 2 runners signed up
-- Week 2: 1 runner
-- Week 3: 1 runner

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
	customer_orders.order_time,
    runner_orders.pickup_time
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id;
        
-- difference in time
SELECT 
	runner_id,
	AVG(TIMESTAMPDIFF(MINUTE, customer_orders.order_date_time, runner_orders.pickup_date_time)) AS avg_minutes_passed
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
GROUP BY 1;

-- Runner 1 averaged about 15 minutes from order to pickup
-- Runner 2 about 23 minutes
-- Runner 3 10 minutes

-- Total average for entire shop, not based on runner
SELECT 
	AVG(TIMESTAMPDIFF(MINUTE, customer_orders.order_date_time, runner_orders.pickup_date_time)) AS avg_minutes_passed
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id;

-- Average time for the shop as a whole between order and pickup is 18 minutes


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT *
FROM customer_orders;
-- Look at order and pickup difference and number of pizzas in order
-- Then use that to make CTE where I will group on count of pizzas and take average of time difference 
-- join runner orders and customer orders

SELECT
	customer_orders.order_id,
    COUNT(customer_orders.pizza_id) AS pizzas_ordered,
    TIMESTAMPDIFF(MINUTE, customer_orders.order_date_time, runner_orders.pickup_date_time) AS pickup_time
FROM customer_orders
	INNER JOIN runner_orders 
		ON customer_orders.order_id = runner_orders.order_id
GROUP BY 1,3;

-- now put this in cte and select the count and avg time, grouping on count
WITH CTE_avg_time AS
(SELECT
	customer_orders.order_id,
    COUNT(customer_orders.pizza_id) AS pizzas_ordered,
    TIMESTAMPDIFF(MINUTE, customer_orders.order_date_time, runner_orders.pickup_date_time) AS time_to_pickup
FROM customer_orders
	INNER JOIN runner_orders 
		ON customer_orders.order_id = runner_orders.order_id
GROUP BY 1,3)


SELECT 
	pizzas_ordered,
    AVG(time_to_pickup) AS avg_minutes
FROM CTE_avg_time
GROUP BY 1;

-- 1 pizza: avg of 12 minutes between order and pickup, 12 minutes to prepare
-- 2 pizzas: avg of 18 minutes
-- 3 pizzas: avg of 29 minutes
-- The more pizzas in an order, the longer it takes to prepare. It seems like less of an impact between one and 2 pizzas, but increases significantly between 2 and 3 pizzas


-- 4. What was the average distance travelled for each customer?
SELECT 
	customer_orders.customer_id,
    AVG(runner_orders.distance) AS avg_distance
FROM customer_orders
	INNER JOIN runner_orders
		ON customer_orders.order_id = runner_orders.order_id
GROUP BY 1;

-- Customer 101 20 km avg
-- Customer 102 16 km avg
-- Customer 103 23 km avg
-- Customer 104 10 km avg
-- Customer 105 25 km avg
-- Customer 104 lives the closest, at 10 km avg
-- Customer 103 and 105 the furthest at 23 and 25 respectively.


-- 5. What was the difference between longest and shortest delivery times for all orders?
SELECT *
FROM runner_orders;

-- Assumption that duration is the time between pickup time and delivery time.
-- Very simple because I changed duration datatype to integer during cleaning
SELECT
	MAX(duration) AS max_time,
    MIN(duration) AS min_time,
	MAX(duration) - MIN(duration) AS diff_duration
FROM runner_orders
WHERE duration IS NOT NULL;

-- Difference in highest (40 minutes) and lowest (10 minutes) times from pickup to delivery is 30 minutes


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

-- Avg speed is km/hour

-- convert duration to hours
SELECT 
	runner_id,
    order_id,
    distance,
    (duration/60) AS time_hour
FROM runner_orders;

-- Now divide that by distance to get km/hour (round 2 places) group on the runner id and order id
SELECT 
	runner_id,
    order_id,
    distance,
    (duration/60) AS time_hour,
    ROUND(distance/(duration/60), 2) AS avg_speed
FROM runner_orders
WHERE distance IS NOT NULL
GROUP BY 1,2,3,4,5
ORDER BY 1;

-- Runner 1 ranged between 37.5 km/hr to 60 km/hour, and the fastest avg speed for this runner was the least distance; they drove faster to the nearer place
-- Runner 3 had 1 order, and this runner had avg speed of 40 km/hour.
-- Runner 2 needs investigating. Between 34.5 and 92 km/hour. And the max and min avg speeds were for travelling the same distance, 23 miles. Look at order time versus pickup time to see if the order was behind.

-- Invesitagting runner id 2.
SELECT
	c.order_id,
    c.order_date_time,
    r.pickup_date_time,
    TIMESTAMPDIFF(MINUTE, c.order_date_time, r.pickup_date_time) AS minutes_prepare,
    r.distance,
    ROUND(r.distance/(r.duration/60), 2) AS avg_speed
FROM customer_orders AS c
	INNER JOIN runner_orders AS r
		ON c.order_id = r.order_id
WHERE duration IS NOT NULL
	AND r.runner_id = 2
GROUP BY 1,2,3,4,5,6,7
ORDER BY 1,2;
-- Upon inspection, the order with fastest avg speed, order 8, was not picked up by the runner until after midnight.
-- It's possible this was this runner's last pizza of the night and they were rushing to deliver.
-- Based on the pickup times and avg speed, I can see Runner 2 drives faster the later it gets in the day. The earlier it is, the slower they drive.


-- 7. What is the successful delivery percentage for each runner?
SELECT *
FROM runner_orders;
-- Successful delivery % is number of orders not cancelled divided by total orders x 100.
-- Could do CTE of count of order id, and sum coutn of case statment where cancellation is not null then query off of that

SELECT
	runner_id,
    COUNT(order_id) AS total_orders,
    SUM(CASE
			WHEN cancellation IS NULL THEN 1 
            ELSE 0 END) AS successful_orders
FROM runner_orders
GROUP BY 1;

-- Now place this inside CTE and query off to get %
WITH CTE_success_rate AS
(SELECT
	runner_id,
    COUNT(order_id) AS total_orders,
    SUM(CASE
			WHEN cancellation IS NULL THEN 1 
            ELSE 0 END) AS successful_orders
FROM runner_orders
GROUP BY 1)

SELECT
	runner_id,
    (successful_orders/total_orders)*100 AS percent_success
FROM CTE_success_rate
GROUP BY 1;

-- Runner 1: 100% success on 4 orders
-- Runner 2: 75% success on 4 orders
-- Runner 3: 50% success on 2 orders.

-- Just very quickly, look at cancellation reasons again
SELECT
	runner_id,
    order_id,
    cancellation
FROM runner_orders
WHERE cancellation IS NOT NULL
ORDER BY 1;

-- Runner 2's 75% success would have been 100 if the customer had not cancelled. Not really the runner's fault
-- Runner 3 only had 2 orders total, and one was cancelled by restaurant giving them a 50% success rate. I don't have the data available to see if it was the runner's fault or not as to why they cancelled. 

