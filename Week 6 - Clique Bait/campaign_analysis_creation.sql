/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 6: CLIQUE BAIT

CAMPAIGN ANALYSIS - TABLE CREATION

*/


-- 1. Generate a table that has 1 single row for every unique visit_id record and has the following columns:
-- user_id
-- visit_id
-- visit_start_time: the earliest event_time for each visit
-- page_views: count of page views for each visit
-- cart_adds: count of product cart add events for each visit
-- purchase: 1/0 flag if a purchase event exists for each visit
-- campaign_name: map the visit to a campaign if the visit_start_time falls within the campaign's start_date and end_date
-- impressions: count of ad impressions for each visit
-- clicks: count of ad clicks for each visit
-- OPTIONAL: cart_products: comma_separated text value with products added to cart sorted by the order they were added to the cart (hint: use sequence number)

-- I will tackle these individually.

-- visit_id and user_id

CREATE TABLE campaign_info (
user_id INT,
visit_id VARCHAR(50));

-- there will be 1 row per visit id, but can be multiple rows for each user_id - if they have multiple visits.
-- use SELECT DISTINCT to pull both of these from events and users tables joined on cookie id.
-- distinct will still pull multiple of a single user_id if there are multiple unique visit ids within that user.

INSERT INTO campaign_info
SELECT DISTINCT
	user_id,
    events.visit_id
FROM events
	INNER JOIN users
		ON events.cookie_id = users.cookie_id
ORDER BY 1;


-- Add column for visit start time
-- this is the min event_time in events_table

ALTER TABLE campaign_info
ADD COLUMN visit_start_time DATETIME;

UPDATE campaign_info
INNER JOIN (
SELECT
	visit_id,
    MIN(event_time) AS start_time
FROM events
GROUP BY 1 ) AS times
ON campaign_info.visit_id = times.visit_id
SET visit_start_time = times.start_time;

-- Add column and values for page views per visit

ALTER TABLE campaign_info
ADD COLUMN page_views INT;

-- For page views, a count of event type 1 per visit id

UPDATE campaign_info
INNER JOIN (
SELECT
	visit_id,
    COUNT(event_type) AS views
FROM events
WHERE event_type = 1
GROUP BY 1 ) AS viewing
ON campaign_info.visit_id = viewing.visit_id 
SET page_views = viewing.views;

-- Add column and values for cart_adds
ALTER TABLE campaign_info
ADD COLUMN cart_adds INT;

-- Cart adds is count of event type 2
UPDATE campaign_info
INNER JOIN (
SELECT
	visit_id,
    COUNT(event_type) AS adds
FROM events
WHERE event_type = 2
GROUP BY 1 ) AS adding
ON campaign_info.visit_id = adding.visit_id
SET cart_adds = adding.adds;

-- There are some null values, no cart_adds happened during that visit. Need to update those to zero.

UPDATE campaign_info
SET cart_adds = 0 WHERE cart_adds IS NULL;


-- Purchase: 0/1 flag

-- Add column for purchase

ALTER TABLE campaign_info
ADD COLUMN purchase INT;

-- Now Add values; 0 is no purchase, 1 is purchase

UPDATE campaign_info
INNER JOIN (
SELECT
	visit_id,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
FROM events
GROUP BY 1 ) AS purchases
ON campaign_info.visit_id = purchases.visit_id
SET campaign_info.purchase = purchases.purchase;

-- Campaign_name: 
-- if visit_start_time falls within a campaign, identify the campaign

-- I would love to join these 2 tables, campaign info and campaign id, but I don't have a data point to connect them.
-- Instead, I'll need to manually pull the dates from the campaign id table and manually input the name of the campaign as well.
-- All of this will be pulled into a case statement

SELECT *
FROM campaign_id;

SELECT 
	visit_id,
    (CASE WHEN visit_start_time > '2020-01-01 00:00:00' AND visit_start_time < '2020-01-14 00:00:00' THEN 'BOGOF - Fishing For Compliments'
		  WHEN visit_start_time > '2020-01-15 00:00:00' AND visit_start_time < '2020-01-28 00:00:00' THEN '25% Off - Living The Lux Life'
          WHEN visit_start_time > '2020-02-01 00:00:00' AND visit_start_time < '2020-03-31 00:00:00' THEN 'Half Off - Treat Your Shell(fish)'
          ELSE NULL END) AS campaign
FROM campaign_info;

-- Now, add a column for campaign and add the values.

ALTER TABLE campaign_info
ADD COLUMN campaign_name VARCHAR(100);

UPDATE campaign_info
INNER JOIN (
SELECT 
	visit_id,
    (CASE WHEN visit_start_time > '2020-01-01 00:00:00' AND visit_start_time < '2020-01-14 00:00:00' THEN 'BOGOF - Fishing For Compliments'
		  WHEN visit_start_time > '2020-01-15 00:00:00' AND visit_start_time < '2020-01-28 00:00:00' THEN '25% Off - Living The Lux Life'
          WHEN visit_start_time > '2020-02-01 00:00:00' AND visit_start_time < '2020-03-31 00:00:00' THEN 'Half Off - Treat Your Shell(fish)'
          ELSE NULL END) AS campaigns
FROM campaign_info ) AS campaign
ON campaign_info.visit_id = campaign.visit_id
SET campaign_info.campaign_name = campaign.campaigns;


-- impression column: count of ad impressions per visit id

SELECT *
FROM event_id;
-- ad impression is event_type 4.

ALTER TABLE campaign_info
ADD COLUMN ad_impressions INT;

UPDATE campaign_info
INNER JOIN (
SELECT 
	visit_id,
    SUM(CASE WHEN event_type = 4 THEN 1 ELSE 0 END) as ad_imp
FROM events
GROUP BY 1 ) AS imp
ON campaign_info.visit_id = imp.visit_id
SET campaign_info.ad_impressions = imp.ad_imp;


-- ad_clicks: count of ad clicks per visit

-- Very similar to above, but for event_type 5.

ALTER TABLE campaign_info
ADD COLUMN ad_clicks INT;

UPDATE campaign_info
INNER JOIN (
SELECT 
	visit_id,
    SUM(CASE WHEN event_type = 5 THEN 1 ELSE 0 END) as ad_clicks
FROM events
GROUP BY 1 ) AS clicks
ON campaign_info.visit_id = clicks.visit_id
SET campaign_info.ad_clicks = clicks.ad_clicks;


-- OPTIONAL COLUMN: cart_products

-- Need to use a concat function to return page_names as comma separated string value within a case statement

WITH cte_cart AS (
SELECT 
	visit_id,
    CASE WHEN event_type = 2 AND product_id IS NOT NULL THEN page_name ELSE NULL END AS cart_products
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id )
        
SELECT
	visit_id,
    group_concat(cart_products) AS cart_prod
FROM cte_cart
GROUP BY 1;
        
-- Add column and values

ALTER TABLE campaign_info
ADD COLUMN cart_products VARCHAR(250);

UPDATE campaign_info
INNER JOIN (
WITH cte_cart AS (
SELECT 
	visit_id,
    CASE WHEN event_type = 2 AND product_id IS NOT NULL THEN page_name ELSE NULL END AS cart_products
FROM events
	INNER JOIN page_hierarchy
		ON events.page_id = page_hierarchy.page_id )
        
SELECT
	visit_id,
    group_concat(cart_products) AS cart_prod
FROM cte_cart
GROUP BY 1 ) AS carts
ON campaign_info.visit_id = carts.visit_id
SET campaign_info.cart_products = carts.cart_prod;


-- I can now use this table, and the various other tables in this database for an analysis in the next section.