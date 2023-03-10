/* 

DANNY MA 8 WEEK SQL CHALLENGE - WEEK 7: Balanced Tree Clothing Company

TRANSACTION ANALYSIS

*/

-- 1. How many unique transactions were there?

SELECT 
	COUNT(DISTINCT txn_id) AS unique_trans
FROM sales;

-- There were 2500 unique transactions.


-- 2. What is the average unique products purchased in each transaction?

WITH cte_txn AS (
SELECT
	COUNT(DISTINCT prod_id) AS txn_products
FROM sales
GROUP BY txn_id )

SELECT
	AVG(txn_products) AS avg_per_txn
FROM cte_txn;

-- 6.04 unique products were purchased per transaction on average.


-- 4. What is the average discount value per transaction?

-- There are 2 ways to answer this. I'll show both.

-- First way: find the total number of unique transactions and the sum of all discounts, then divide the sum by the total transaction count to get avg discount per transaction.
WITH cte_discount AS (
SELECT
	COUNT(DISTINCT txn_id) AS txn_count,
    SUM(discount) AS total_discount
FROM sales )

SELECT
	(total_discount/txn_count) AS avg_discount
FROM cte_discount;

-- Second way: find the discount per unique transaction for every transaction, and then take the average of those discounts.
WITH cte_avg AS (
SELECT 
	txn_id,
    SUM(discount) AS total_discount
FROM sales
GROUP BY 1
ORDER BY 2 DESC )

SELECT
	AVG(total_discount) AS avg_discount
FROM cte_avg;

-- Either way, the avg discount per transaction is $73.08.


-- 5. What is the percentage split of all transactions for members versus non-members?

-- First, MAX of case statements for member column grouped by txn_id
-- Not SUM because each txn_id should only have 1 or 0 for member or non member

SELECT 
	txn_id,
    MAX(CASE WHEN member = 't' THEN 1 ELSE 0 END) AS member_txn,
    MAX(CASE WHEN member = 'f' THEN 1 ELSE 0 END) AS non_member
FROM sales
GROUP BY 1;

-- Now, place this in cte
-- Query cte to find sum of each column divided by the sum of both * 100 and rounded to 2 places for percent breakdown.

WITH cte_member AS (
SELECT 
	txn_id,
    MAX(CASE WHEN member = 't' THEN 1 ELSE 0 END) AS member_txn,
    MAX(CASE WHEN member = 'f' THEN 1 ELSE 0 END) AS non_member
FROM sales
GROUP BY 1 )

SELECT
	ROUND((SUM(member_txn)/(SUM(member_txn) + SUM(non_member)))*100.0,2) AS pct_member,
    ROUND((SUM(non_member)/(SUM(member_txn) + SUM(non_member)))*100.0,2) AS pct_nonmember
FROM cte_member;

-- 60.2% of all transactions were made by members.
-- 39.8% of all transactions were made by non-members.


-- 6. What is the average revenue for member transactions and non-member transactions?

-- another case statement for members and nonmembers that returns the qty*price grouped by transaction id to find rev per transaction
-- making non members NULL (not 0) in members column, and members NULL in nonmembers column
-- NULL values are ignored by avg functions, while 0s are included; I don't want the averages affected by the wrong member type so to work around this, and ignore them, make them NULL.

SELECT 
	txn_id,
    SUM(CASE WHEN member = 't' THEN (price*qty) ELSE NULL END) AS member_total,
	SUM(CASE WHEN member = 'f' THEN (price*qty) ELSE NULL END) AS nonmember_total
FROM sales
GROUP BY 1;

-- Now, put this in a cte
-- Query off of it to get avg of each column

WITH cte_avg AS (
SELECT 
	txn_id,
    SUM(CASE WHEN member = 't' THEN (price*qty) ELSE NULL END) AS member_total,
	SUM(CASE WHEN member = 'f' THEN (price*qty) ELSE NULL END) AS nonmember_total
FROM sales
GROUP BY 1 )

SELECT 
	ROUND(AVG(member_total),2) AS avg_member_rev,
    ROUND(AVG(nonmember_total),2) AS avg_nonmember_rev
FROM cte_avg;

-- Members had an avg revenue per transaction of 516.27
-- Nonmembers had an avg revenue per transaction of 515.04.
-- Very little difference between member transactions and nonmember transactions.
-- However, we know there is a larger amount of member transactions than nonmembers, based on question 5, so members drive more revenue.







