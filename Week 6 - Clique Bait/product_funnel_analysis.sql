/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 5: CLIQUE BAIT

PRODUCT FUNNEL ANALYSIS

*/

USE clique_bait;


-- 1. In a single query, create a table which has the following output:
-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to cart but not purchased (abandoned)?
-- How many times was each product purchased?

-- I am going to answer each of these questions individually, and then consolidate those 4 queries into the table.

-- Product views:

SELECT *
FROM page_hierarchy;

SELECT *
FROM event_id;
-- event_type 1 is page view.

SELECT *
FROM events
WHERE event_type = 1;

SELECT 
    events.page_id,
    page_name,
    product_id,
    event_type
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE events.event_type = 1;

-- Now, group by page_name and count page_id and filter out results where product_id is null
SELECT
	page_name,
    COUNT(events.page_id) AS views
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE events.event_type = 1
AND product_id IS NOT NULL
GROUP BY 1;


-- Added to Cart:

-- Very similar to first query.
-- Instead of event type 1, I want event type 2.
SELECT
	page_name,
    COUNT(events.page_id) AS added_to_cart
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE events.event_type = 2
AND product_id IS NOT NULL
GROUP BY 1;


-- Abandoned:

-- I'll actually come back to this - first, I'll do purchased!
-- Once I have how many times each product was purchased, I can simply subtract the purchased column from the cart_adds column to get how many times each product was abandoned!

-- Purchased:

-- Event type 3
-- Did a query in previous exercise that I will slightly modify to fit here.

WITH cte_products AS (
SELECT 
	visit_id,
    CASE WHEN event_type = 2 THEN page_id ELSE NULL END AS cart_products
FROM events ),

cte_products_not_null AS (
SELECT	
	*
FROM cte_products
WHERE cart_products IS NOT NULL ) ,

cte_purchases AS (
SELECT
	visit_id,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchased
FROM events
GROUP BY 1 ),

cte_purchased AS (
SELECT 
	*
FROM cte_purchases 
WHERE purchased = 1 ) ,

cte_products_purchased AS (
SELECT
	cte_purchased.visit_id, 
    cart_products
FROM cte_products_not_null
	INNER JOIN cte_purchased 
		ON cte_products_not_null.visit_id = cte_purchased.visit_id ) ,

cte_final AS (        
SELECT 
	*
FROM cte_products_purchased
	INNER JOIN page_hierarchy
		ON cte_products_purchased.cart_products = page_hierarchy.page_id )

SELECT
    page_name,
    COUNT(cart_products) AS qty_purchased
FROM cte_final
GROUP BY 1
ORDER BY 2 DESC;


-- Now, I will place this all in a table. Once I've made the table, I can subtract the 2 columns for the final question - abandoned products.

-- I'm actually going to add to this table individually by column.
-- It's possible to use 1 single query if I use subqueries, but the query will be incredibly long and inefficient in my opinion.
DROP TABLE IF EXISTS product_info;
CREATE TABLE product_info (
product_name VARCHAR (50),
views INT );

INSERT INTO product_info
SELECT
	page_name,
    COUNT(events.page_id) AS views
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE events.event_type = 1
AND product_id IS NOT NULL
GROUP BY 1;

-- Add column for cart_adds

ALTER TABLE product_info
ADD COLUMN cart_adds INT;


UPDATE product_info 
INNER JOIN (
SELECT
	page_name,
    COUNT(events.page_id) AS cart_adds
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE events.event_type = 2
AND product_id IS NOT NULL
GROUP BY 1 ) AS t1
	ON product_info.product_name = t1.page_name
SET product_info.cart_adds = t1.cart_adds;


-- Now add column for purchased items.

ALTER TABLE product_info
ADD column purchases INT;

UPDATE product_info
INNER JOIN (
WITH cte_products AS (
SELECT 
	visit_id,
    CASE WHEN event_type = 2 THEN page_id ELSE NULL END AS cart_products
FROM events ),

cte_products_not_null AS (
SELECT	
	*
FROM cte_products
WHERE cart_products IS NOT NULL ) ,

cte_purchases AS (
SELECT
	visit_id,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchased
FROM events
GROUP BY 1 ),

cte_purchased AS (
SELECT 
	*
FROM cte_purchases 
WHERE purchased = 1 ) ,

cte_products_purchased AS (
SELECT
	cte_purchased.visit_id, 
    cart_products
FROM cte_products_not_null
	INNER JOIN cte_purchased 
		ON cte_products_not_null.visit_id = cte_purchased.visit_id ) ,

cte_final AS (        
SELECT 
	*
FROM cte_products_purchased
	INNER JOIN page_hierarchy
		ON cte_products_purchased.cart_products = page_hierarchy.page_id )

SELECT
    page_name,
    COUNT(cart_products) AS qty_purchased
FROM cte_final
GROUP BY 1
ORDER BY 2 DESC ) AS t2
	ON product_info.product_name = t2.page_name
SET product_info.purchases = t2.qty_purchased;


-- Finally, I'll add a column for abandoned (or added to cart with no purchase).
-- For this column's values, I'll simply subtract purchases from cart_adds.

ALTER TABLE product_info
ADD COLUMN qty_abandoned INT;
    
UPDATE product_info
SET qty_abandoned = cart_adds - purchases;	

SELECT *
FROM product_info;

-- TA DA! (:
-- While I broke it down into multiple queries tp illustrate my thought process and make the queries more readable, I have an end result of table with all of the requested info.