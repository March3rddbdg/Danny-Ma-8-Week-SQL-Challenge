/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 5: CLIQUE BAIT

PRODUCT FUNNEL ANALYSIS

*/



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


-- 2. Additionally, create another table which further aggregates the data for the above points
-- This time, for the Product Categories, not the individual products.

-- Product categories and views:

-- views = event_type 1
SELECT *
FROM page_hierarchy
WHERE product_category IS NOT NULL; 

SELECT
	product_category,
    COUNT(event_type) AS views
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE product_category IS NOT NULL
AND event_type = 1
GROUP BY 1;

CREATE TABLE category_info (
product_category VARCHAR(30),
views INT );

INSERT INTO category_info
SELECT
	product_category,
    COUNT(event_type) AS views
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE product_category IS NOT NULL
AND event_type = 1
GROUP BY 1;

-- cart_adds:

ALTER TABLE category_info
ADD COLUMN cart_adds INT;

UPDATE category_info
INNER JOIN (
SELECT
	product_category,
    COUNT(event_type) AS cart_adds
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE product_category IS NOT NULL 
AND event_type = 2
GROUP BY 1 ) AS adds
ON category_info.product_category = adds.product_category
SET category_info.cart_adds = adds.cart_adds;

-- Purchases

ALTER TABLE category_info
ADD COLUMN purchases INT;


UPDATE category_info
INNER JOIN (
WITH cte_cats AS (
SELECT
	visit_id,
    CASE WHEN event_type = 2 THEN product_category ELSE NULL END AS added_cats
FROM events
	INNER JOIN page_hierarchy 
		ON events.page_id = page_hierarchy.page_id ) ,
        
cte_added_cats AS (
SELECT
	*
FROM cte_cats
WHERE added_cats IS NOT NULL ),

cte_purchases AS (
SELECT
	visit_id,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchases
FROM events
GROUP BY 1 ) ,

cte_purchased_cats AS (
SELECT
	*
FROM cte_purchases 
WHERE purchases = 1 )

SELECT
	added_cats,
    COUNT(added_cats) AS purchased_qty
FROM cte_added_cats
	INNER JOIN cte_purchased_cats
		ON cte_added_cats.visit_id = cte_purchased_cats.visit_id
GROUP BY 1 ) AS cat_purch
ON category_info.product_category = cat_purch.added_cats 
SET category_info.purchases = cat_purch.purchased_qty;

-- Now, add column and values for abandoned categories.

ALTER TABLE category_info
ADD COLUMN qty_abandoned INT;

UPDATE category_info
SET qty_abandoned = cart_adds - purchases;

SELECT *
FROM category_info;

-- category_info table is complete!


-- 3. Using the 2 new output tables, answer the following questions:

-- a. Which product has the most views, cart_adds, and purchases?

-- most views:
SELECT
	product_name,
    views
FROM product_info
ORDER BY 2 DESC;

-- Oyster has the most views.

-- cart_adds:

SELECT
	product_name,
    cart_adds
FROM product_info
ORDER BY 2 DESC;

-- Lobster has the most cart-adds.

-- Purchases:

SELECT
	product_name,
    purchases
FROM product_info
ORDER BY 2 DESC;

-- Lobster also has the most purchases.


-- b. Which product is most likely to be abandoned?

SELECT
	product_name,
    qty_abandoned
FROM product_info
ORDER BY 2 DESC;

-- Russian Caviar is most likely to be abandoned.


-- c. Which product has highest view-to-purchase percentage?

-- To find this percentage, I need to take (purchases/views) *100.0

SELECT
	product_name,
    ROUND((purchases/views)*100.0,2) AS view_purchase_percent
FROM product_info
ORDER BY 2 DESC;

-- Lobster had the highest view-to-purchase percentage!


-- d. What is the average conversion rate from view to cart add?

-- Conversion rate is just how many views turned into (or converted to) cart_adds.
-- To find this, divide cart_add by views *100.0.
-- Then take average!

SELECT
	AVG(ROUND((cart_adds/views)*100.0, 2)) AS avg_conv
FROM product_info;

-- 60.95% of views converted to cart adds. 
-- Could also use the catogory information table, the numbers will be slightly off because the data is more consolidated in category table. 

-- e. What is the average conversion rate from cart_add to purchase?

-- Same as above, only with cart_adds and purchases.

SELECT	
	AVG(ROUND((purchases/cart_adds)*100.0,2)) AS avg_conv
FROM product_info;

-- 75.93% of cart adds resulted in purchase.

