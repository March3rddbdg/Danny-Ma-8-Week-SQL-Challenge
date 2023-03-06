/*

DANNY MA 8 WEEK SQL CHALLENGE: WEEK 5 - DATA MART

DATA EXPLORATION

*/

-- 1.What day of the week is used for each week_date value?

SELECT
	DAYNAME(week_date) AS day_of_week
FROM clean_weekly_sales;

-- Monday is the day each week starts on!


-- 2. What range of week numbers are missing from the dataset?
-- First, I'll need to make a table of all weeks in a year (1-52) and then join the temp table to find what's missing

DROP TABLE IF EXISTS week_numbers;
CREATE TEMPORARY TABLE week_numbers (
week_number INT) ;

INSERT INTO week_numbers 
VALUES 
('1'),
('2'),
('3'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9'),
('10'),
('11'),
('12'),
('13'),
('14'),
('15'),
('16'),
('17'),
('18'),
('19'),
('20'),
('21'),
('23'),
('23'),
('24'),
('25'),
('26'),
('27'),
('28'),
('29'),
('30'),
('31'),
('32'),
('33'),
('34'),
('35'),
('36'),
('37'),
('38'),
('39'),
('40'),
('41'),
('42'),
('43'),
('44'),
('45'),
('46'),
('47'),
('48'),
('49'),
('50'),
('51'),
('52');

-- Now, I'll left join week numbers to clean weekly sales where clean weekly sales week number is null
-- make sure to start with week numbers table and left join it, as the weeks remaining after where filter will be those not in the clean table

SELECT 
	week.week_number
FROM week_numbers AS week
	LEFT JOIN clean_weekly_sales AS sales
		ON week.week_number = sales.week_number
WHERE sales.week_number IS NULL;
-- Weeks 1-11 and 36-52 are missing from our dataset.


-- 3. How many total transactions were there for each year in dataset?

-- SUM of transactions grouped by year

SELECT
	calendar_year,
	SUM(transactions) AS trans_per_year
FROM clean_weekly_sales
GROUP BY 1
ORDER BY 1;
-- 2018: 346,406,460 transactions
-- 2019: 365,639,285 transactions
-- 2020: 375,813,651 transactions


-- 4. What is total sales of each region for each month?
SELECT *
FROM clean_weekly_sales;
-- Do a sum of sales grouped on region and month

SELECT
	region,
    month_number,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY 1,2
ORDER BY 1,2;
-- 	Resulting table shows total sales per month for each region for months in dataset, March-September


-- 5. What is the total count of transactions for each platform?
-- Transactions column is already a count on that particular day
-- Do a sum of transactions grouped on platform
SELECT 
	platform,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY 1;
-- Retail: 1,081,934,227
-- Shopify: 5,925,169
-- Online, or shopify, is less common than in-store purchases


-- 6. What is the percent of sales for Retail vs. Shopify for each month?

-- looking at grouping on platform again.
-- using sales column
-- For general numbers:
SELECT
	platform,
    ROUND((SUM(sales)/(SELECT SUM(sales)
				FROM clean_weekly_sales))*100.0, 2) AS pct_sales
FROM clean_weekly_sales
GROUP BY 1;

-- The Retail platform makes up over 97% of all sales. Shopify nearly 3%.
-- Now for the breakdown by month!
WITH cte_monthly AS (
SELECT
	calendar_year,
    month_number,
    platform,
    SUM(sales) AS monthly_sales
FROM clean_weekly_sales
GROUP BY 1,2,3 ),
cte_breakdown AS (
SELECT
	calendar_year,
    month_number,
    CASE
		WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END AS retail_sales,
	CASE 
		WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END AS shopify_sales
FROM cte_monthly ),
cte_totals AS (
SELECT
	calendar_year,
    month_number,
    SUM(retail_sales) + SUM(shopify_sales) AS total_monthly_sales
FROM cte_breakdown
GROUP BY 1,2 )

SELECT 
	cte_totals.calendar_year,
    cte_totals.month_number,
    ROUND((retail_sales/total_monthly_sales)*100.0,2) as pct_retail,
    ROUND((shopify_sales/total_monthly_sales)*100.0,2) as pct_shopify
FROM cte_breakdown
	INNER JOIN cte_totals
		ON cte_breakdown.calendar_year = cte_totals.calendar_year
        AND cte_breakdown.month_number = cte_totals.month_number
ORDER BY 1,2,3,4;
-- Retail is consistently between 96% - 97%	and Shopify is consistently 2-3%.
-- It does look like shopify was more in the 2% range until April of 2020 when it increased to 3% range.
-- Could be getting more popular, or slightly more people were ordering online due to pandemic?


-- 7. What is percentage of sales by demographic for each year?

-- Total sales by year
WITH cte_annual AS (
SELECT
	calendar_year,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY 1
ORDER BY 1 ),
 cte_dem AS (
SELECT
	calendar_year,
	demographic,
    SUM(sales) AS total_by_dem
FROM clean_weekly_sales
GROUP BY 1,2
ORDER BY 1,2 ),
cte_demo AS (
SELECT
	ann.calendar_year,
    ann.total_sales,
    SUM(CASE WHEN demographic = 'Couples' THEN total_by_dem ELSE NULL END) AS couple_total,
    SUM(CASE WHEN demographic = 'Families' THEN total_by_dem ELSE NULL END) AS fam_total,
	SUM(CASE WHEN demographic = 'Unknown' THEN total_by_dem ELSE NULL END) AS unknown_total
FROM cte_annual AS ann
	JOIN cte_dem AS dem
		ON ann.calendar_year = dem.calendar_year
GROUP BY 1,2 )

SELECT
	calendar_year,
    ROUND((couple_total/total_sales)*100.0,2) as couple_pct,
    ROUND((fam_total/total_sales)*100.0,2) as fam_pct,
    ROUND((unknown_total/total_sales)*100.0,2) as unknown_pct
FROM cte_demo
GROUP BY 1,2,3;
-- 2018: roughly 26% sales from couples, 32% from families, 42% unknown origin
-- 2019: roughly 27% sales from couples, 32% from families, 20% unknown origin
-- 2020: roughly 29% sales from couples, 33% from families, 39% unknown origin
-- These are pretty consistent, I don't see a large jump in percentage from any year within any of the categories.
-- The unknown percent does decrease, perhaps because less customers had unknown information.


-- 8. Which age_brand and demographic values contribute most to Retail Sales?
-- First pull sum of sales grouped on age_band and demo and filtered by retail sales

SELECT
	age_band,
    demographic,
    SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY 1,2
ORDER BY 3 DESC;

-- Can see that unknown age_band and unknown demographic have highest total sales.
-- Of known values, Retiree Families are highest, followed by Retiree Couples. Retirees make up large segment of total sales!
-- Can also break this down by percent
-- sum of sales is by segment, but can take the sum of that to get total to divide the segment sum by
-- use OVER() within percentage calculation to get running percentage - no argument or partition, just want the percentage broken by whole set

SELECT
	age_band,
    demographic,
    SUM(sales) AS retail_sales,
   ROUND(100*SUM(sales)/SUM(SUM(sales)) OVER(),2 ) AS percent
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY 1,2
ORDER BY 3 DESC;
-- Can clearly see the contribution of each group with percentages to confirm earlier insights


-- 9. Can we use avg_transaction column to find avg transaction size for each year for Retail vs. Shopify? 
--  If not, how would I calculate?

-- No, because avg_transaction is taking the average already of transactions and sales for each data point on date.
-- Calculate doing the same math (sales/transactions) for retail and shopify as filters

SELECT
	calendar_year,
	platform,
    ROUND(SUM(sales)/SUM(transactions),2) AS avg_trans
FROM clean_weekly_sales
GROUP BY 1,2;
-- On average, Shopify customers spend significantly more per transaction.
-- Roughly 5-6 times what in-store/retail shoppers spend per transaction.

    






