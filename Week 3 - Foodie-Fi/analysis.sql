/*

DANNY MA 8 WEEK SQL CHALLENGE: WEEK 3 - FOODIE-FI

DATA ANALYSIS QUESTIONS

*/

-- 1. How many customers has Foodie-Fi ever had?
SELECT 
	COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;

-- Foodie-Fi has had 1000 customers so far.


-- 2. What is the monthly distribution of trial plan start date values?

--    Using start of month as group by value
SELECT 
	*
FROM subscriptions
WHERE plan_id = 0;

-- Asking for monthly number of users here.
-- First break the start date column into a piece with just the month
SELECT
	customer_id,
    start_date,
    substring_index(substring_index(start_date, '-', 2), '-', -1) AS month_start
FROM subscriptions
WHERE plan_id = 0;

SELECT
	customer_id,
    start_date,
    MONTH(start_date) AS month_start
FROM subscriptions
WHERE plan_id = 0;

-- now, need a count of customer ids falling into each month
WITH cte_month_start AS
(SELECT
	customer_id,
    start_date,
    substring_index(substring_index(start_date, '-', 2), '-', -1) AS month_start,
    MONTH(start_date) AS month
FROM subscriptions
WHERE plan_id = 0)

SELECT 
	month_start,
    MONTHNAME(start_date) AS month_name,
    COUNT(customer_id) AS total_customers
FROM cte_month_start
GROUP BY 1,2
ORDER BY 3 DESC;

-- March had most free trial signups at 94.
-- February had least with 68.


-- 3. What plan start date values occur after the year 2020?

-- Show the breakdown by count of events for each plan
-- Need to group by plan_id
-- Limit results to after 2020-12-31
SELECT 
	sub.plan_id,
    plans.plan_name,
	COUNT(sub.plan_id) AS number_of_events
FROM subscriptions AS sub
	INNER JOIN plans
		ON sub.plan_id = plans.plan_id
WHERE sub.start_date > '2020-12-31'
GROUP BY 1,2;

-- Starting January 1st 2021:
-- 71 customers cancelled, 
-- 60 upgraded to promonthly, 
-- 63 upgraded to pro annual,
-- and 8 upgraded to basic monthly.
-- No values for plan id 0, or free trial. Meaning no new signups for free service starting in 2021?
-- Let's exmaine that
SELECT *
FROM subscriptions
WHERE plan_id = 0;
-- Yes, it looks like there were no new signups after the year 2020.


-- 4. What is the customer count and percentage of customers who have churned, rounded to 1 decimal point?

-- Churned, or cancelled, is plan 4.
-- First need to find the count
SELECT 
	sub.plan_id,
    COUNT(*) AS customer_count
FROM subscriptions AS sub
	INNER JOIN plans AS plans
		ON sub.plan_id = plans.plan_id
GROUP BY 1;
-- Now, I'll need to do a subquery in select clause to be able to pull the grand total of all customers to get the churn percent
-- If I don't use subquery, the filter will cause the percentage to be incrrect because it won't be looking at every single customer (it would then only look at the filter i apply, or plan id 4).
SELECT
	plan_id,
    COUNT(*) AS churn_customers,
    (COUNT(*)/(
				SELECT COUNT(DISTINCT customer_id)
                FROM subscriptions))*100 AS churned_percent
FROM subscriptions
WHERE plan_id = 4;

-- Now, round to 1 decimal place
SELECT
	plan_id,
    COUNT(*) AS churn_customers,
    ROUND((COUNT(*)/(
				SELECT COUNT(DISTINCT customer_id)
                FROM subscriptions))*100, 1) AS churned_percent
FROM subscriptions
WHERE plan_id = 4;

-- 307 customers cancelled, or 30.7%


-- 5. How many customers churned right after the initial free trial?
--    What is the percentage rounded o the nearest whole number?

-- This is asking which customers went from plan id 0 to plan id 4.
-- Another way of thinking about it is their plan id went to 4 7 days after their plan id was 0.

-- If I use ROW NUMBER, paritioned by customer and ordered by plan, this will rank the progression of plans within each customer
-- A customer with a plan id of 4 (churned) and a rank of 2 means that they cancelled after the free trial
SELECT
	customer_id,
    plan_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS ranking
FROM subscriptions;

-- Now make this a cte
WITH cte_rank AS (
SELECT
	customer_id,
    plan_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS ranking
FROM subscriptions)

SELECT 
	COUNT(customer_id) AS immediate_churn
FROM cte_rank
WHERE plan_id = 4 AND ranking = 2;

-- Now, I'll need to do a similar subquery as I did in previous question to pull the percentage
WITH cte_rank AS (
SELECT
	customer_id,
    plan_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS ranking
FROM subscriptions)

SELECT 
	COUNT(customer_id) AS immediate_churn,
    (COUNT(customer_id)/(
						SELECT COUNT(DISTINCT customer_id)
                        FROM subscriptions))*100 AS percent_churn
FROM cte_rank
WHERE plan_id = 4 AND ranking = 2;

-- Now round to nearest whole number
WITH cte_rank AS (
SELECT
	customer_id,
    plan_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS ranking
FROM subscriptions)

SELECT 
	COUNT(customer_id) AS immediate_churn,
    ROUND((COUNT(customer_id)/(
						SELECT COUNT(DISTINCT customer_id)
                        FROM subscriptions)*100),0) AS percent_churn
FROM cte_rank
WHERE plan_id = 4 AND ranking = 2;

-- 92 customers, or 9%, immediately cancelled service following free trial period.


-- 6. What is the number and percentage of plans after the initial free trial.

-- Use row_number to rank their subscriptions - rank 1 is initial free trial, rank 2 is what immediately follows which is what I'll filter by

SELECT
	customer_id,
    plan_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS ranking
FROM subscriptions;

-- Now put this into CTE and filter on rank 2
WITH cte_rank AS (
SELECT
	customer_id,
    plan_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS ranking
FROM subscriptions )

SELECT 	
	customer_id,
    plan_id
FROM cte_rank
WHERE ranking = 2;

-- Now, pull the select statement into cte and do count of each plan id
WITH cte_rank AS (
SELECT
	customer_id,
    plan_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS ranking
FROM subscriptions ),
cte_plans AS (
SELECT 	
	customer_id,
    plan_id
FROM cte_rank
WHERE ranking = 2 )

SELECT
	plan_id,
	COUNT(plan_id) AS count_of_plan
FROM cte_plans
GROUP BY 1;

-- Now place this in cte, then do same select statement, with one additional clause of subquery for percent
 WITH cte_rank AS (
SELECT
	customer_id,
    plan_id,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY plan_id) AS ranking
FROM subscriptions ),
cte_plans AS (
SELECT 	
	customer_id,
    plan_id
FROM cte_rank
WHERE ranking = 2 ),
cte_count AS (
SELECT
	plan_id,
	COUNT(plan_id) AS count_of_plan
FROM cte_plans
GROUP BY 1)

SELECT
	plan_id,
    count_of_plan,
    ROUND((count_of_plan/(SELECT 
					SUM(count_of_plan)
					FROM cte_count))*100,2) AS pct_plan
FROM cte_count
GROUP BY 1,2;
-- Plan 1 had 546 customers, or 54.6% choose after free trial
-- Plan 2 had 37 customers, or 3.7% choose after free trial
-- Plan 3 had 325 customers, or 32.5% choose
-- Plan 4 had 92 customers, or 9.2% churn or cancel
-- Basic monthly and pro annual make up over 85% of customer's inital choice following free trial
-- Pro monthly has lowest representation - lower than cancellations too - meaning foodie-fi needs to discover what the drawbacks or customer hesitancies are to this plan 


-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT *
FROM plans;
-- Annual plan is plan_id 3.

-- going to select count of distinct customer ids where plan id is 3 AND the year of the start date is 2020.
SELECT
	COUNT(DISTINCT customer_id) AS cust_count
FROM subscriptions
WHERE plan_id = 3
AND YEAR(start_date) = '2020';

-- 195 customers upgraded to the annual plan in 2020.


-- 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join foodie-fi?

-- going to make 2 ctes with trial plan (plan_id 0) and annual plan (plan_id 3) and subtract the dates between them
WITH cte_trial AS (
SELECT
	customer_id,
    start_date AS trial_date
FROM subscriptions 
WHERE plan_id = 0 ),
cte_annual AS (
SELECT 
	customer_id,
    start_date AS annual_date
FROM subscriptions 
WHERE plan_id = 3)

SELECT
	datediff(annual_date, trial_date) AS days_to_convert
FROM cte_trial
	INNER JOIN cte_annual
		ON cte_trial.customer_id = cte_annual.customer_id;

-- Now I'll use this same statement and just take the average of the date_diff. May need to also round, depending on the result
WITH cte_trial AS (
SELECT
	customer_id,
    start_date AS trial_date
FROM subscriptions 
WHERE plan_id = 0 ),
cte_annual AS (
SELECT 
	customer_id,
    start_date AS annual_date
FROM subscriptions 
WHERE plan_id = 3)

SELECT
	ROUND(AVG(datediff(annual_date, trial_date)),0) AS days_to_convert
FROM cte_trial
	INNER JOIN cte_annual
		ON cte_trial.customer_id = cte_annual.customer_id;
-- On average, it takes 105 days from the customer's free trial start to convert to an annual plan.


-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- Use what I have above, manipulate the last statement into a cte, then do case statements

WITH cte_trial AS (
SELECT
	customer_id,
    start_date AS trial_date
FROM subscriptions 
WHERE plan_id = 0 ),
cte_annual AS (
SELECT 
	customer_id,
    start_date AS annual_date
FROM subscriptions 
WHERE plan_id = 3),
cte_avg AS (
SELECT
	datediff(annual_date, trial_date) AS days_to_convert
FROM cte_trial
	INNER JOIN cte_annual
		ON cte_trial.customer_id = cte_annual.customer_id),
cte_brackets AS (        
SELECT
	CASE 
		WHEN days_to_convert BETWEEN 0 AND 30 THEN '30_days'
        WHEN days_to_convert BETWEEN 31 AND 60 THEN '60_days'
        WHEN days_to_convert BETWEEN 61 AND 90 THEN '90_days'
        WHEN days_to_convert > 90 THEN 'over_90_days'
        END AS conversion_brackets
FROM cte_avg )

SELECT
	conversion_brackets,
	COUNT(conversion_brackets) AS bracket_breakdown
FROM cte_brackets
GROUP BY 1;

-- 49 customers upgraded within 30 days
-- 24 customers upgraded within 60 days
-- 34 customers upgraded within 90 days
-- 151 customers upgraded after 90 days
-- The vast majority of customers seem to cycle through other plans before finally choosig the annual option
-- Foodie-Fi may want to examine how they could increase the number of customers upgrading to an annual plan sooner than that!


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

-- This is asking how many customers went from plan 2 down to plan 1.
-- Can use the lead function here to find the next date and what the plan id is, then pull into a cte and query to find count of distinct customer ids where plan_id is 2 and new_plan is 1

SELECT
	customer_id,
    plan_id,
    start_date,
    LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS new_plan
FROM subscriptions;

WITH cte_lead AS (
SELECT
	customer_id,
    plan_id,
    start_date,
    LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS new_plan
FROM subscriptions)

SELECT 
	COUNT(DISTINCT customer_id) AS number_downgraded
FROM cte_lead
WHERE YEAR(start_date) = '2020'
AND plan_id = 2
AND new_plan = 1;

-- Hm, it appears that 0 customers downgraded from PRO to BASIC monthly in 2020.


