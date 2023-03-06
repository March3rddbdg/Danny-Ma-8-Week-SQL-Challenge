/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 5: CLIQUE BAIT

DIGITAL ANALYSIS

*/

-- 1. How many users are there?

SELECT 
	COUNT(DISTINCT user_id) AS unique_users
FROM users;

-- There are 500 users.


-- 2. How many cookies does each user have on average?

-- First, need to run count of unique cookie ids grouping on user id'
-- Then I'll place this inside a cte and query to find avg of cookie_count

SELECT
	user_id,
    COUNT(DISTINCT cookie_id) AS cookie_count
FROM users
GROUP BY 1;

-- Now, the cte and subsequent query

WITH cte_cookie AS (
SELECT
	user_id,
    COUNT(DISTINCT cookie_id) AS cookie_count
FROM users
GROUP BY 1 )

SELECT 
	AVG(cookie_count) AS avg_cookies
FROM cte_cookie;

-- I need to round this average to nearest whole cookie, or to 0 places, since you can't have a fraction of a cookie.

WITH cte_cookie AS (
SELECT
	user_id,
    COUNT(DISTINCT cookie_id) AS cookie_count
FROM users
GROUP BY 1 )

SELECT 
	ROUND(AVG(cookie_count), 0) AS avg_cookies
FROM cte_cookie;

-- Each user has about 4 cookies.


-- 3. What is the unique number of visits by all users per month?

-- I need to pull a count of unique visit_id grouped on the month of the event_time from the events table.

SELECT 
	MONTH(event_time) AS month,
    COUNT(DISTINCT visit_id) AS unique_visits
FROM events
GROUP BY 1
ORDER BY 1;

-- January, month 1, had 876 unique visits.
-- February, month 2, had 1488 unique visits. This was the highest in terms of visits.
-- March, month 3, had 916 unique visits.
-- April, month 4, had 248 unique visits.
-- May, month 5, had 36 unique visits. This was the lowest by far.


-- 4. What is the number of events for each event type?

-- Using the events table, do a count(*) grouped on event_type.
-- Count(*) because I want to count the number of entries for each event type.

SELECT
	event_type,
    COUNT(*) AS event_count
FROM events
GROUP BY 1;

-- Can take this a step further and join event_id table to also get name of event.

SELECT
	events.event_type,
    event_name,
    COUNT(*) AS event_count
FROM events
	INNER JOIN event_id 
		ON events.event_type = event_id.event_type
GROUP BY 1,2;

-- 1, Page View: 20,928 events. The highest number of events, which is typical in digital analyses.
-- 2, Add to Cart: 8,451 events.
-- 3, Purchase: 1, 777 events. A little less than 1/8 Add to Cart events lead to Purchase events.
-- 4, Ad Impression: 876 events.
-- 5, Ad Click: 702. The lowest.


-- 5. What is the percentage of visits which have a purchase event?

-- I'll join events and event_id tables on event_type
-- Then count unique visit id filtering on event_name purchase
-- Divide that count by a subquery counting unique visit id with no filter

SELECT
	COUNT(DISTINCT visit_id)/(SELECT COUNT(DISTINCT visit_id)
				FROM events)*100 AS percent_purchase
FROM events
	INNER JOIN event_id
		ON events.event_type = event_id.event_type
WHERE event_name = 'Purchase';

-- Round the percent to 2 decimal places.

SELECT
	ROUND(COUNT(DISTINCT visit_id)/(SELECT COUNT(DISTINCT visit_id)
				FROM events)*100,2) AS percent_purchase
FROM events
	INNER JOIN event_id
		ON events.event_type = event_id.event_type
WHERE event_name = 'Purchase';

-- 49.86% of all visits result in Purchase. That's a high conversion rate! 
-- I'm going to double check that math:
SELECT
	COUNT(DISTINCT visit_id) AS unique_total_visits
FROM events;
-- 3564 unique visits.

SELECT
	COUNT(DISTINCT visit_id) AS unique_total_visits
FROM events
	INNER JOIN event_id 
		ON events.event_type = event_id.event_type
WHERE event_name = 'Purchase';
-- 1777 Purchases.
-- 1777/3564 = 49.86%. What an amazing conversion rate! 


-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

-- Breaking this down, I first need a count of visits ids which have an event id for checkout but not purchase.
SELECT *
FROM event_id;
SELECT *
FROM page_hierarchy;

-- Page id 12 is checkout. Page id 13 is confirmation, meaning they've purchased.
-- I want a count of user ids that include page_id 12 but not page_id 13, or not event_type 3.

SELECT
	visit_id,
	CASE WHEN event_type = 1 OR event_type = 2 AND page_id = 12 THEN 1 ELSE 0 END AS no_purchase,
    CASE WHEN event_type = 3 THEN 1 ELSE 0 END AS purchase
FROM events;

-- This gives me a table which has purchase column that only has a 1 if a Purchase was made.
-- Now, I can put this in a cte and query off of it to count visit ids where purchase column is 0.
-- In order to that though, I need to consolidate each visit id into 1 row; pull max of CASE statements
-- By pulling the max, if the visit id has a case where event type = purchase, or there is a 1 in purchase column, it will display that.

SELECT
	visit_id,
	MAX(CASE WHEN event_type <> 3 AND page_id = 12 THEN 1 ELSE 0 END) AS no_purchase,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM events
GROUP BY 1;
-- Now, I can query off of this to count the visit ids where purchase = 0. 
WITH cte_purchase AS (
SELECT
	visit_id,
	MAX(CASE WHEN event_type <> 3 AND page_id = 12 THEN 1 ELSE 0 END) AS no_purchase,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM events
GROUP BY 1 )

SELECT
	COUNT(DISTINCT visit_id) AS count_without_purchase
FROM cte_purchase
WHERE purchase = 0;

-- 1787 visit ids viewed the checkout page without completing a purchase.
-- Now, the question asked for a percent of this. Need to subtract no purchase from purchase and divide that by purchase.
-- Modify above query to find number of visit ids resulting in purchase and not.

WITH cte_purchase AS (
SELECT
	visit_id,
	MAX(CASE WHEN event_type <> 3 AND page_id = 12 THEN 1 ELSE 0 END) AS no_purchase,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM events
GROUP BY 1 )

SELECT
	SUM(purchase) AS purchase_total,
    SUM(no_purchase) AS total_without_purchase,
    ROUND(((SUM(no_purchase) - SUM(purchase))/SUM(no_purchase))*100,2) as pct_no_purchase
FROM cte_purchase;

-- 1777 purchased, 2103 did not. Subtract purchase from non-purchase to get difference that didn't purchase and divide that by purchase total.
-- 15.50% made it to confirmation page without making a purchase.


-- 7. What are the top 3 pages by number of views?

-- Need to count the number of views (count all, not DISTINCT because a user could view a pgae more than once) of each page and order count descending limit 3.

SELECT
	events.page_id,
    page_name,
    COUNT(*) AS number_of_views
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3;

-- 1: All Products with 4752 views.
-- 2: Lobster with 2515 views.
-- 3. Crab with 2513 views.
-- Very interesting that the home page isn't in the top! 


-- 8. What is the number of views and cart adds for each product category?

-- Going to do a case statement of some kind.

SELECT *
FROM page_hierarchy;

SELECT *
FROM event_id;

-- Need to find when event_type is 1 and when event_type is 2 and do a count of those grouped by product category.
-- Case statement with sum of each to caterogize the sum by product category.

SELECT 
	product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_added
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
GROUP BY 1;
    
-- Pages like Home Page will have 'NULL' as product_category, so let's filter those out.

SELECT 
	product_category,
    SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS cart_added
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id
WHERE product_category IS NOT NULL
GROUP BY 1;

-- Shellfish: 6204 page views, 3792 cart added. Most page views and cart added!
-- Luxury: 3032 page views, 1870 cart added.
-- Fish: 4633 page views, 2789 cart_added.


-- 9. What are the top 3 products by purchases?

-- Multi-step process. 
-- First, need to pull the visit_id and the page_id when event is Add to Cart, or 2. Also add a sum of case statement where event_type = 3 gives 1 in a purchase column, which will show which of those actually resulted in purchases.

SELECT 
	visit_id,
	CASE WHEN event_type = 2 THEN page_id ELSE NULL END AS products_in_cart,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM events
GROUP BY 1,2;

-- Actually, going to remove 3rd statement in select clause and place remaining statement in cte,
-- Then, I'll make another cte with that third statement, 
-- Then I'll inner join the 2 on visit_id to then only show products that were actually purchased
-- After that, I'll need to continue creating cte's off of the previous one to find the count of each product, as well as what that page_id actually is in terms of the product.
-- My final queries will count each product that was purchased to see which has most, and order descending and limit 3 to find top 3.

WITH cte_products AS (
SELECT 
	visit_id,
	CASE WHEN event_type = 2 THEN page_id ELSE NULL END AS products_in_cart
FROM events ),

cte_products_not_null AS (
SELECT *
FROM cte_products
WHERE products_in_cart IS NOT NULL ),

cte_purchase AS (
SELECT 
	visit_id,
	MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM events
GROUP BY 1 ),

cte_products_purchased AS (
SELECT
	cte_purchase.visit_id,
    products_in_cart
FROM cte_products_not_null
	INNER JOIN cte_purchase
		ON cte_products_not_null.visit_id = cte_purchase.visit_id
WHERE purchase = 1 ),

cte_qty_purchased AS (
SELECT
	products_in_cart,
    COUNT(products_in_cart) AS number_purchased
FROM cte_products_purchased
GROUP BY 1
ORDER BY 2 DESC ),

cte_final AS (
SELECT
	*
FROM cte_qty_purchased
	INNER JOIN page_hierarchy
		ON cte_qty_purchased.products_in_cart = page_hierarchy.page_id )
        
SELECT
	product_id,
    number_purchased,
    page_name
FROM cte_final
ORDER BY 2 DESC
LIMIT 3;

-- Top 3 Products Purchased:    
-- Page_id 7: Lobster, 754 purchased.
-- Page_id 9: Oyster, 726 purchased.
-- Page_id 8: Crab, 719 purchased.





    
    




	