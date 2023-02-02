/*


Danny Ma 8 Week SQL Challenge Week 2: "Pizza Runner"


*/

-- Database Creation
CREATE SCHEMA pizza_runner;
USE pizza_runner;

-- Table Creation
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
/*

CLEANING

*/

-- 1. Check out runners table.
SELECT *
FROM runners;
-- Looks good.


-- 2. Customer Orders table.
SELECT *
FROM customer_orders;

-- A few issues here.
-- Exclusions and extras columns have blanks, correct null entries, incorrect null entries.
-- Use update table to ensure nulls are correctly placed and formatted.
UPDATE customer_orders
SET exclusions = NULL WHERE exclusions = '';
UPDATE customer_orders
SET exclusions = NULL WHERE exclusions = 'null';
UPDATE customer_orders
SET extras = NULL WHERE extras = '';
UPDATE customer_orders
SET extras = NULL WHERE extras = 'null';

-- Also split order_time into order_date and order_time to make it more usable
SELECT
	*,
	CAST(order_time AS time) AS order_time,
    CAST(order_time AS date) AS order_date
FROM customer_orders;

ALTER TABLE customer_orders
ADD COLUMN order_date DATE;

UPDATE customer_orders
SET order_date = CAST(order_time AS date);

ALTER TABLE customer_orders
ADD COLUMN time_order TIME;

UPDATE customer_orders
SET time_order = CAST(order_time AS time);

ALTER TABLE customer_orders
RENAME COLUMN order_time TO order_date_time;

ALTER TABLE customer_orders
RENAME COLUMN time_order TO order_time;

SELECT *
FROM customer_orders;

-- Much better. Nulls are added in correctly and the date and time are separated to be more usable.


-- 3. Check Runner Orders table.
SELECT *
FROM runner_orders;

-- First, pickup_time column cleanup with nulls, then splitting into date and time columns
UPDATE runner_orders
SET pickup_time = NULL WHERE pickup_time = 'null';

ALTER TABLE runner_orders
RENAME COLUMN pickup_time TO pickup_date_time;

SELECT 
	*,
    CAST(pickup_date_time AS date) AS pickup_date,
    CAST(pickup_date_time AS time) AS pickup_time
FROM runner_orders;

ALTER TABLE runner_orders
ADD COLUMN pickup_date DATE AFTER pickup_date_time;

ALTER TABLE runner_orders
ADD COLUMN pickup_time TIME AFTER pickup_date;

UPDATE runner_orders
SET pickup_date = CAST(pickup_date_time AS date);

UPDATE runner_orders
SET pickup_time = CAST(pickup_date_time AS time);

-- Beautiful.
-- Now, distance column has incorrectly formatted null, also has inconsistent distance tracking.
-- Reformat null.
UPDATE runner_orders
SET distance = NULL WHERE distance = 'null';

-- Remove the distance metric - km and retype column as int
SELECT
	*,
    CASE
		WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
        WHEN distance LIKE '% km' THEN TRIM(' km' FROM distance)
        ELSE distance
        END AS distance
FROM runner_orders;

UPDATE runner_orders
SET distance = CASE
		WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
        WHEN distance LIKE '% km' THEN TRIM(' km' FROM distance)
        ELSE distance
        END;

-- Now do same with duration column and minutes
UPDATE runner_orders
SET duration = NULL WHERE duration = 'null';

SELECT 
	*,
    CASE 
		WHEN duration LIKE '% minutes' THEN TRIM(' minutes' FROM duration)
        WHEN duration LIKE '% mins' THEN TRIM(' mins' FROM duration)
        WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
        WHEN duration LIKE '% minute' THEN TRIM(' minute' FROM duration)
        WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
        ELSE duration END
FROM runner_orders;

UPDATE runner_orders
SET duration = CASE 
		WHEN duration LIKE '% minutes' THEN TRIM(' minutes' FROM duration)
        WHEN duration LIKE '% mins' THEN TRIM(' mins' FROM duration)
        WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
        WHEN duration LIKE '% minute' THEN TRIM(' minute' FROM duration)
        WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
        ELSE duration END; 
SELECT *
FROM runner_orders;

ALTER TABLE runner_orders
MODIFY COLUMN distance INT;

ALTER TABLE runner_orders
MODIFY COLUMN duration INT;


-- Last order of business: clean up nulls in cancellation column

UPDATE runner_orders
SET cancellation = NULL WHERE cancellation = '';

UPDATE runner_orders
SET cancellation = NULL WHERE cancellation = 'null';

SELECT *
FROM runner_orders;


-- 4. Check pizza names table.
SELECT *
FROM pizza_names;


-- 5. Check pizza recipes.
SELECT *
FROM pizza_recipes;


-- 6. Check pizza toppings.
SELECT *
FROM pizza_toppings;


-- Data is now sparkling clean in each table. (:

  
