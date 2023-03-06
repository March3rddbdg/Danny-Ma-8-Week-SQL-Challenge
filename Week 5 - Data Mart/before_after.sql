/*

DANNY MA 8 WEEK SQL CHALLENGE: WEEK 5 - DATA MART

BEFORE AND AFTER ANALYSIS

*/

-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
-- Using this analysis approach - answer the following questions:

-- 1. What are total sales for 4 weeks before and after the change on 6/15/2020?
--    What is the growth or reduction rate in actual values and percentage of sales?

SELECT
	*
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';

-- The date of change is in Week 24. 
-- Now I need 4+ and 4- weeks from week 24. Make sure week 24 is included in after

SELECT
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number IN ('20','21','22','23','24','25','26','27')
AND calendar_year = '2020'
GROUP BY 1
ORDER BY 1;
-- use this query, add lag function to make another column
-- then I will subtract the lag column from the total column to get my delta of sales, or change in actual value of sales week to week
-- use the change in value to also get rate of change
WITH cte_lag AS (
SELECT
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number IN ('20','21','22','23','24','25','26','27')
AND calendar_year = '2020'
GROUP BY 1
ORDER BY 1 ),
cte_sales AS (
SELECT
	week_number,
    total_sales,
    LAG(total_sales, 1) OVER(ORDER BY week_number) AS lag_sales
FROM cte_lag
GROUP BY 1,2
ORDER BY 1 )

SELECT
	week_number,
    total_sales,
    lag_sales,
    total_sales-lag_sales AS delta_sales,
    ROUND(((total_sales-lag_sales)/total_sales)*100,2) AS rate_change,
    ROUND(total_sales/(SELECT SUM(total_sales) FROM cte_lag)*100.0,2) AS pct_sales
FROM cte_sales
GROUP BY 1,2,3
ORDER BY 1;
-- The rates of change alternate positive and negative week to week, BUT they're more drastic after the change
-- The largest 2 negative rates of change were after the switch, week 24 and week 26.
-- The sales seemed, based on rate of change, much more stable before this switch.
-- Besides week 27, the 4th week of change, all of the larger percent sales were before the change.
-- These differences in percent sales are very slight, tenths and hundreds of a percent, but that equates to large amounts of sales.

-- Now I'll look at total sales for 4 weeks before and total for 4 weeks after and compare the 2
WITH cte_sum AS (
SELECT
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE (week_number BETWEEN '20' AND '27')
GROUP BY 1
ORDER BY 1 ),
cte_switch AS (
SELECT	
	SUM(CASE
		WHEN week_number BETWEEN '20' AND '23' THEN total_sales END) AS before_switch,
	SUM(CASE
		WHEN week_number BETWEEN '24' AND '27' THEN total_sales END) AS after_switch
FROM cte_sum )
SELECT
	before_switch,
    after_switch,
    after_switch - before_switch AS difference,
    ((after_switch - before_switch) /before_switch)*100.0 AS percent_change
FROM cte_switch;

-- Clearly, Datamart has seen a decrease in sales since making the switch.

-- 2. What about the entire 12 weeks before and after?
--  This is asking for above information, but of the entire dataset
-- Going to do essentially the same, but without filtering on week
WITH cte_lag AS (
SELECT
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY 1
ORDER BY 1
),
cte_sales AS (
SELECT
	week_number,
    total_sales,
    LAG(total_sales, 1) OVER(ORDER BY week_number) AS lag_sales
FROM cte_lag
GROUP BY 1,2
ORDER BY 1 )

SELECT 
	week_number,
    total_sales,
    lag_sales,
    (total_sales - lag_sales) AS delta_sales,
    ROUND(((total_sales - lag_sales)/total_sales)*100.0,2) AS rate_change,
    ROUND((total_sales/(SELECT SUM(total_sales) FROM cte_lag))*100.0,2) AS percent_sales
FROM cte_sales
GROUP BY 1,2,3
ORDER BY 1;

-- I'm going to actually pull the 12 weeks before and after into their own views so I can sum the completely to get a bigger picture overview
WITH cte_totals AS (
SELECT
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales	
WHERE (week_number BETWEEN 12 AND 35) 
AND calendar_year = '2020'
GROUP BY 1
ORDER BY 1 ),
cte_switch AS (
SELECT 
	SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_switch,
	SUM(CASE
		WHEN week_number >= 24 THEN total_sales END) AS after_switch
FROM cte_totals )

SELECT
	before_switch,
    after_switch,
    after_switch - before_switch AS difference,
    ((after_switch - before_switch)/before_switch)* 100.0 AS change_rate
FROM cte_switch;
-- Clearly, even with a larger sample of data, Datamart made less in sales after they made the switch.
-- The larger sample actually illustrates that their sales have decreased by just over 2% since making this change!


-- 3. How do the sales metrics for these 2 periods, before and after, compare with the previous years in 2019 and 2018?

-- I'm going to use the above queries for the 12 week before and after period to compare "apples to apples" in 2019 and 2018.
-- There wasn't a switch in anything in those years, so this analysis will tell me what this particular time of year looked like in years passed to determine if it was the switch in 2020 that caused the dip in sales.
-- 2019:
WITH cte_totals AS (
SELECT
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales	
WHERE (week_number BETWEEN 12 AND 35) 
AND calendar_year = '2019'
GROUP BY 1
ORDER BY 1 ),
cte_switch AS (
SELECT 
	SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_24,
	SUM(CASE
		WHEN week_number >= 24 THEN total_sales END) AS after_24
FROM cte_totals )

SELECT
	before_24,
    after_24,
    after_24 - before_24 AS difference,
    ((after_24 - before_24)/before_24)* 100.0 AS change_rate
FROM cte_switch;
-- In 2019, there was a slight decrease in sales totals in this timeframe as well
-- However, the dip in sales in 2020 after the switch was -2%, while in 2019 it was less than half a percent point.

-- 2018:
WITH cte_totals AS (
SELECT
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales	
WHERE (week_number BETWEEN 12 AND 35) 
AND calendar_year = '2018'
GROUP BY 1
ORDER BY 1 ),
cte_switch AS (
SELECT 
	SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_24,
	SUM(CASE
		WHEN week_number >= 24 THEN total_sales END) AS after_24
FROM cte_totals )

SELECT
	before_24,
    after_24,
    after_24 - before_24 AS difference,
    ((after_24 - before_24)/before_24)* 100.0 AS change_rate
FROM cte_switch;
-- Interesting! In 2018, Datamart actually saw an INCREASE in sales from weeks 12-23 to weeks 24-35.
-- It was a robust increase of 1.6%.
-- Given that 2018 saw an increase in sales in this timeframe, and 2019 saw a minute dip in sales, compared to the 2% dip in 2020, it's likely that the switch in 2020 did contribute to that dip in sales.

-- I am going to show all 3 in the same table!
WITH cte_totals AS (
SELECT
	calendar_year,
	week_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales	
WHERE (week_number BETWEEN 12 AND 35) 
GROUP BY 1,2
ORDER BY 1,2 ),
cte_switch AS (
SELECT 
	calendar_year,
	SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_24,
	SUM(CASE
		WHEN week_number >= 24 THEN total_sales END) AS after_24
FROM cte_totals
GROUP BY 1
ORDER BY 1 )

SELECT
	calendar_year,
	before_24,
    after_24,
    after_24 - before_24 AS difference,
    ((after_24 - before_24)/before_24)* 100.0 AS change_rate
FROM cte_switch
GROUP BY 1
ORDER BY 1;


-- BONUS QUESTION!
-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period? 
 -- region, platform, age_band, demographic, customer__type.
 -- region:
WITH cte_region AS (
SELECT
	week_number,
    region,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE (week_number BETWEEN 12 AND 35)
AND calendar_year = '2020'
GROUP BY 1,2
ORDER BY 1,2 ),
cte_totals AS (
SELECT
	region,
    SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_24,
	SUM(CASE
        WHEN week_number >= 24 THEN total_sales END) AS after_24
FROM cte_region
GROUP BY 1
ORDER BY 1 )

SELECT
	region,
    before_24,
    after_24,
    after_24 - before_24 AS difference,
    ((after_24 - before_24)/before_24)*100.0 AS rate_change
FROM cte_totals
GROUP BY 1
ORDER BY 1;
-- In terms of rate of change, Asia most negatively impacted the loss after the switch.
-- Interesting, there was ONE region where there was a positive rate of change, higher sales, AFTER the switch, and by nearly 5%! Europe seemed to embrace this switch!
-- In terms of raw values, Oceania saw the biggest loss in sales, over 71,000,000 less than the 12 weeks before the change! Oceania also had the 2nd highest negatively impacting rate of change.

-- Platform:
WITH cte_platform AS (
SELECT
	week_number,
    platform,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE (week_number BETWEEN 12 AND 35)
AND calendar_year = '2020'
GROUP BY 1,2
ORDER BY 1,2 ),
cte_totals AS (
SELECT
	platform,
    SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_24,
	SUM(CASE
        WHEN week_number >= 24 THEN total_sales END) AS after_24
FROM cte_platform
GROUP BY 1
ORDER BY 1 )

SELECT
	platform,
    before_24,
    after_24,
    after_24 - before_24 AS difference,
    ((after_24 - before_24)/before_24)*100.0 AS rate_change
FROM cte_totals
GROUP BY 1
ORDER BY 1;
-- Retail clearly had higher negative impact, as retail had a -2.4 rate of change, while Shopify actually saw a 7% increase in sales following the switch!
-- Shopify does have a significantly smaller total sales raw number, so each sales dollar has a higher impact on the percentage.
-- Retail saw a dip in sales of over 168,000,000! Eeek! 
-- To compare, the increase in Shopify before and after was nearly 16,000,000, about 10% of the loss Retail saw.

-- age_band:
WITH cte_age AS (
SELECT
	week_number,
    age_band,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE (week_number BETWEEN 12 AND 35)
AND calendar_year = '2020'
GROUP BY 1,2
ORDER BY 1,2 ),
cte_totals AS (
SELECT
	age_band,
    SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_24,
	SUM(CASE
        WHEN week_number >= 24 THEN total_sales END) AS after_24
FROM cte_age
GROUP BY 1
ORDER BY 1 )

SELECT
	age_band,
    before_24,
    after_24,
    after_24 - before_24 AS difference,
    ((after_24 - before_24)/before_24)*100.0 AS rate_change
FROM cte_totals
GROUP BY 1
ORDER BY 1;
-- Unknown had the highest negative impact at 3.3%.
-- Because unknown is, well, unknown, it doesn't give me much information. ):
-- The second group with the highest negative impact was Middle-Aged.
-- None of the age groups had positive impact at all - all groups saw dips in sales following the change.

-- demographic:
WITH cte_dem AS (
SELECT
	week_number,
    demographic,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE (week_number BETWEEN 12 AND 35)
AND calendar_year = '2020'
GROUP BY 1,2
ORDER BY 1,2 ),
cte_totals AS (
SELECT
	demographic,
    SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_24,
	SUM(CASE
        WHEN week_number >= 24 THEN total_sales END) AS after_24
FROM cte_dem
GROUP BY 1
ORDER BY 1 )

SELECT
	demographic,
    before_24,
    after_24,
    after_24 - before_24 AS difference,
    ((after_24 - before_24)/before_24)*100.0 AS rate_change
FROM cte_totals
GROUP BY 1
ORDER BY 1;
-- Again, Unknown has highest negative rate of change.
-- Families had a rate of change over double of Couples, showing families saw a bigger drop in sales following the change.

-- customer_type:
WITH cte_cust AS (
SELECT
	week_number,
    customer_type,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE (week_number BETWEEN 12 AND 35)
AND calendar_year = '2020'
GROUP BY 1,2
ORDER BY 1,2 ),
cte_totals AS (
SELECT
	customer_type,
    SUM(CASE
		WHEN week_number < 24 THEN total_sales END) AS before_24,
	SUM(CASE
        WHEN week_number >= 24 THEN total_sales END) AS after_24
FROM cte_cust
GROUP BY 1
ORDER BY 1 )

SELECT
	customer_type,
    before_24,
    after_24,
    after_24 - before_24 AS difference,
    ((after_24 - before_24)/before_24)*100.0 AS rate_change
FROM cte_totals
GROUP BY 1
ORDER BY 1;
-- Very interesting! New customers show sales GROWTH after the change! This could indicate general growth or interest in Datamart after/because of the switch.
-- Guest customers had a higher negative rate of change than existing customers. It seems guests were unhappy with the switch.


  
    