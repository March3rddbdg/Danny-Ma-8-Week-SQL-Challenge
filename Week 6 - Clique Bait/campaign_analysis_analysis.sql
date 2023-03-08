/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 6: CLIQUE BAIT

CAMPAIGN ANALYSIS - INDIVIDUAL ANALYSIS

*/

-- Use the newly created dataset to generate at least 5 insights for the Clique Bait team
-- My analysis will focus on likelihood of purchase and the various factors increasing it.


-- 1. Do the number of views have any impact on purchase rate?

SELECt
	visit_id,
    page_views,
    purchase
FROM campaign_info
ORDER BY 2 DESC;

-- Most page views in 1 visit was 12 views, and no purchase resulted in this.

-- I'll break down the 11 and 10 page view visits, as well as the 3, 4 and 5 page view visits.

-- 11 views: 
WITH cte_view AS (
SELECT 
	visit_id,
    page_views,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS non_purchasers
FROM cte_view
WHERE page_views = 11;

-- 94 of 105 visits with 11 views resulted in a purchase. 89.52% purchase rate at 11 views.
-- Only 11 of 105 visits with 11 views resulted in no purchase. 10.48% non-purchase rate at 11 views.

-- 10 views: 
WITH cte_view AS (
SELECT 
	visit_id,
    page_views,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS non_purchasers
FROM cte_view
WHERE page_views = 10;

-- 232 out of 277 visits with 10 views resulted in a purchase. 83.75% purchase rate at 10 views.
-- 45 out of 277 visits with 10 views resulted in no purchase. 16.25% no purchase rate at 10 views.

-- 5 views:
WITH cte_view AS (
SELECT 
	visit_id,
    page_views,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS non_purchasers
FROM cte_view
WHERE page_views = 5;

-- 98 out of 226 visits with 5 views resulted in a purchase. 43.36% purchase rate for 5 views. 
-- 128 out of 226 visits with 5 views resulted in no purchase. 56.64% no purchase rate for 5 views.

-- 4 views: 
WITH cte_view AS (
SELECT 
	visit_id,
    page_views,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS non_purchasers
FROM cte_view
WHERE page_views = 4;

-- 29 out of 107 visits with 4 views resulted in a purchase. 27.10% purchase rate for 4 views.
-- 78 out of 107 visits with 4 views resulted in no purchase. 72.90% no purchase rate for 4 views.

-- 3 views:

WITH cte_view AS (
SELECT 
	visit_id,
    page_views,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS non_purchasers
FROM cte_view
WHERE page_views = 3;

-- 0 out of 36 visits with 3 views resulted in a purchase.

-- INSIGHT: As the number of views per visit decreases, the likelihood of purchase decreases.


-- 2. Do ad-impressions or clicks have any impact on purchase rate?

-- ad impressions:

WITH cte_imp AS (
SELECT
	visit_id,
    ad_impressions,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS no_purchasers
FROM cte_imp
WHERE ad_impressions = 1;

-- The most ad impressions was 1; visits either had 1 ad impression or 0.
-- Out of the 876 visits which had 1 ad impression, 737 made a purchase. Only 139 did not.
-- INSIGHT: 
-- 1 ad impression per visit had a purchase rate of 84.13%. 
-- 1 ad impression per visit has a higher purchase rate than 10 page views per visit.

WITH cte_imp AS (
SELECT
	visit_id,
    ad_impressions,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS no_purchasers
FROM cte_imp
WHERE ad_impressions = 0;

-- As suspected, when visits did not have an ad impression, more often than not, a purchase did not result from this visit.
-- Out of 2688 visits with no ad impressions, only 1040 visits resulted in a purchase. 1648 did not.
-- No ad impressions had a 38.69% purchase rate.

-- INSIGHT: Even just 1 ad impression per visit significantly impacted the purchase rate.


-- ad clicks:

SELECT
	MAX(ad_clicks)
FROM campaign_info;

-- Like ad impressions, most ad clicks per visit is 1.

WITH cte_clicks AS (
SELECT
	visit_id,
    ad_clicks,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS no_purchasers
FROM cte_clicks
WHERE ad_clicks = 1;

-- Out of 702 visits with 1 ad click, the overwhelming majority, 624 visits, resulted in a purchase.
-- That's an 89.46% purchase rate.
-- That's nearly the purchase rate of visits with 11 views. -0.06 less.

WITH cte_clicks AS (
SELECT
	visit_id,
    ad_clicks,
    CASE WHEN purchase = 1 THEN 'YES' ELSE NULL END AS purchase,
    CASE WHEN purchase = 0 THEN 'NO' ELSE NULL END AS no_purchase
FROM campaign_info
ORDER BY 2 DESC )

SELECT
	COUNT(purchase = 'YES') AS purchasers,
    COUNT(no_purchase = 'NO') AS no_purchasers
FROM cte_clicks
WHERE ad_clicks = 0;

-- Again, as suspected, visits with 0 ad clicks were much less likely to make a purchase.
-- Of the 2862 visits with no ad clicks, only 1153 resulted in a purchase. This is a 40.29% purchase rate.

-- Another insight, in both cases of ad clicks and ad impressions, there were far more visits with 0 ad interactions, either click or impression. 
-- Meaning while even 1 ad interaction significantly increases the likelihood of a purchase, most visits do not have an ad interation.


-- 3. Does number of visits per user id affect the number of purchases?

SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC;

-- The most visits per user is 12.
WITH cte_visits AS (
SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	COUNT(user_id) AS user_qty
FROM cte_visits
WHERE visits = 12;

-- Out of 500 users total, 27 had 12 visits.
WITH cte_visits AS (
SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	ROUND(AVG(purchases),2) as avg_purchases,
    MAX(purchases) AS most_purchases,
    MIN(purchases) AS least_purchases
FROM cte_visits
WHERE visits = 12;

-- The average number of purchases of those 27 users who had 12 visits was 6.63 purchases.
-- The most purchases by a single user with 12 visits was 9 purchases.
-- The least purchases by a single user with 12 visits was 3 purchases.
-- No users with 12 visits had less than 3 purchases, essentially. 
-- This means that users with 12 visits had a 100% purchase rate.

-- Let's look at 10 visits per user, 9 visits per user, 5 visits per user.
-- no users had 11 visits.
-- 10 visits per user:

WITH cte_visits AS (
SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	COUNT(user_id) AS users,
	ROUND(AVG(purchases),2) as avg_purchases,
    MAX(purchases) AS most_purchases,
    MIN(purchases) AS least_purchases
FROM cte_visits
WHERE visits = 10;

-- 74 users had 10 visits.
-- The avg number of purchases for those 74 users was 5.16.
-- The user with the most purchases made 8 purchases, the least made 2 purchases.
-- These numbers are very similar to, just slightly less than, those 27 users who had 12 visits.
-- Again, users with 10 visits had a 100% purchase rate. 
-- This shows so far that the number of visits does affect the likelihood of purchase events, and possible the number of them as well.

-- 9 visits per user: no users had 9 visits.
-- Let's try 8 visits.

WITH cte_visits AS (
SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	COUNT(user_id) AS users,
	ROUND(AVG(purchases),2) as avg_purchases,
    MAX(purchases) AS most_purchases,
    MIN(purchases) AS least_purchases
FROM cte_visits
WHERE visits = 8;

-- 166 users had 8 visits. So I can see a pattern developing where there may be more users with less visits than users with higher visits.
-- The avg number of purchases of those 166 users was 4.01 purchases. 
-- The most purchases by a single user was 7, the least 1. These number are just one less each from the 10 visits per user numbers.
-- Again, there is 100% purchase rate among those users with 8 visits.

-- 5 visits: 0 users with 5 visits
-- 0 users with 7 visits
-- 6 visits:
WITH cte_visits AS (
SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	COUNT(user_id) AS users,
	ROUND(AVG(purchases),2) as avg_purchases,
    MAX(purchases) AS most_purchases,
    MIN(purchases) AS least_purchases
FROM cte_visits
WHERE visits = 6; 

-- there were 138 users who visited 6 times. This is less than the number of users with 8 visits, so perhaps it isn't a trend that more users have less visits.
-- The avg number of purchases of those 138 users was 2.8 purchases per user.
-- The user with the most purchases had 6 purchases. Again, only one less than the max of users with 8 visits.
-- AHA! Finally, we have at least 1 user with 0 purchases. We have lost our 100% purchase rate at 6 visits per user.
-- That is to say, if a user has 8+ visits, we can confidently predict that they will make a purchase.
-- Let's check how many users did not make a purchase at 6 visits.

WITH cte_visits AS (
SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	COUNT(user_id) AS users
FROM cte_visits
WHERE visits = 6
AND purchases = 0;
-- 3 users with 6 visits did not make a purchase. 
-- Users with 6 visits have a 97.83% purchase rate. That's still very high.

-- Let's spot check 2 visits.
WITH cte_visits AS (
SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	COUNT(user_id) AS users,
	ROUND(AVG(purchases),2) as avg_purchases,
    MAX(purchases) AS most_purchases,
    MIN(purchases) AS least_purchases
FROM cte_visits
WHERE visits = 2;

WITH cte_visits AS (
SELECT 
	user_id,
    COUNT(visit_id) AS visits,
    SUM(purchase) AS purchases
FROM campaign_info
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	COUNT(user_id) AS users
FROM cte_visits
WHERE visits = 2
AND purchases = 0;

-- 5 users out of 18 total with 2 visits did not make a purchase. 
-- My early theory that the number of users would increase as number of visits decreased was incorrect.
-- Users with 2 visits had a 72.22% purchase rate. Not too bad!
-- The avg number of purchases for users with 2 visits is .94, almost 1 purchase per user.
-- The most purchases by a user was 2. Least 0.
-- 2 visits is also the lowest number of visits any user has.


-- INSIGHT RECAP:
-- 1. As the number of views per visit increase, the likelihood of purchase increases.
-- 2. Just 1 ad impression per visit has a higher likelihood of purchase than a visit with 10 page views.
-- 3. Just 1 ad click per visit also has a higher likelihood of purchase than a visit with 10 page views. It also nearly matched the purchase rate of visits with 11 page views.
-- 4. The number of visits with 1 ad click or 1 ad impression were higher than the number of visits with 10 or 11 page views. But the majority of visits did not have an ad click or impression.
-- 5. Follow up to 4: If company could increase the number of visits with ad interaction (either impression or click), they would increase the number of purchases.
-- 6. As the number of visits per user increases, the likelihood of purchase increases.
-- 7. 8 visits per user is the lowest number of visits where every user made at least 1 purchase. Even at 6 visits per user, the purchase rate was 97.83%.
-- 8. Most users have more than 5 visits. This means that even though the purchase rate drops below 97.83% with 4 visits or fewer per user, most users are visiting more than 5 times.
