/* 

DANNY MA 8 WEEK SQL CHALLENGE: WEEK 4 - DATA BANK

CUSTOMER TRANSACTIONS

*/

SELECT *
FROM customer_transactions;

-- 1. What is the unique count and total amount for each transaction type?

-- Need to pull txn_type, count of txn_type as well as sum of txn_amount grouped on txn_type
SELECT
	txn_type,
    COUNT(txn_type) AS total_txns,
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY 1;

-- Deposit: 2671 transactions for $1,359,168
-- Withdrawal: 1580 transactions for $793,003
-- Purchase: 1671 transactions for $806,537


-- 2. What is the average total historical deposit counts and amounts for all customers?

-- count of transactions and sum amount grouped on customer_id where type is deposit
-- then put this in cte and take avg of count and amount
SELECT
	customer_id,
    COUNT(*) AS transaction_count,
    AVG(txn_amount) AS total_amount
FROM customer_transactions
WHERE txn_type = 'deposit'
GROUP BY 1;

WITH cte_totals AS (
SELECT
	customer_id,
    COUNT(*) AS transaction_count,
    AVG(txn_amount) AS avg_amount
FROM customer_transactions
WHERE txn_type = 'deposit'
GROUP BY 1 )

SELECT
	AVG(transaction_count) AS avg_transactions,
    AVG(avg_amount) AS avg_total
FROM cte_totals;

-- Now, round avg transactions to 0 places, and avg amount to 2 places
WITH cte_totals AS (
SELECT
	customer_id,
    COUNT(*) AS transaction_count,
    AVG(txn_amount) AS avg_amount
FROM customer_transactions
WHERE txn_type = 'deposit'
GROUP BY 1 )

SELECT
	ROUND(AVG(transaction_count),0) AS avg_transactions,
    ROUND(AVG(avg_amount), 2) AS avg_total
FROM cte_totals;
-- On average, Data Bank customers have 5 deposit transactions for an average amount of 508.61


-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

-- Need to first determine the date range in dataset
SELECT
	MONTH(txn_date) AS month_number
FROM customer_transactions;
-- 4 months: January to April

-- Now, I need to loop in a case statement
SELECT
	customer_id,
    MONTH(txn_date) AS month_number,
    SUM(CASE 
		WHEN txn_type = 'deposit' THEN 1
        ELSE 0 END) AS deposit_number,
	SUM(CASE
		WHEN txn_type = 'withdrawal' OR 'purchase' THEN 1
        ELSE 0 END) AS non_deposit_total
FROM customer_transactions
GROUP BY 1,2
ORDER BY 1;

-- Place this in cte and query off to find where deposit >1 and non_deposit >= 1.
WITH cte_types AS (
SELECT
	customer_id,
    MONTH(txn_date) AS month_number,
    SUM(CASE 
		WHEN txn_type = 'deposit' THEN 1
        ELSE 0 END) AS deposit_number,
	SUM(CASE
		WHEN txn_type = 'withdrawal' OR 'purchase' THEN 1
        ELSE 0 END) AS non_deposit_total
FROM customer_transactions
GROUP BY 1,2
ORDER BY 1 )

SELECT
	*
FROM cte_types
WHERE deposit_number > 1
AND non_deposit_total >= 1
GROUP BY customer_id, month_number
ORDER BY customer_id;

-- Now place above query in another cte, and pull month number and count of customer_ids, grouping on month number
WITH cte_types AS (
SELECT
	customer_id,
    MONTH(txn_date) AS month_number,
    SUM(CASE 
		WHEN txn_type = 'deposit' THEN 1
        ELSE 0 END) AS deposit_number,
	SUM(CASE
		WHEN txn_type = 'withdrawal' OR 'purchase' THEN 1
        ELSE 0 END) AS non_deposit_total
FROM customer_transactions
GROUP BY 1,2
ORDER BY 1 ),
cte_deposits AS (
SELECT
	*
FROM cte_types
WHERE deposit_number > 1
AND non_deposit_total >= 1
GROUP BY customer_id, month_number
ORDER BY customer_id )

SELECT 
	month_number,
    COUNT(customer_id) AS customer_count
FROM cte_deposits
GROUP BY 1
ORDER BY 1;

-- In January: 117 customers had more than 1 deposit and at least one withdrawal or purchase
-- In February: 142 customers had more than 1 deposit and at least one withdrawal or purchase
-- In March: 155 customers had more than 1 deposit and at least one withdrawal or purchase
-- In April: 50 customers had more than 1 deposit and at least one withdrawal or purchase

-- March and February were close to the same, with March edging out as the busiest month for deposits and one other transaction
-- April was a very slow month - not many customers met these criteria.


-- 4. What is the closing balance for each customer at the end of the month?

-- For this problem, I need to add any deposit transactions, and subtract withdrawals and purchases. Or, assign positive and negatives to these values.
WITH cte_month AS (
SELECT
	customer_id,
    MONTH(txn_date) AS txn_month,
    txn_type,
    txn_amount
FROM customer_transactions
ORDER BY 1,2 )

SELECT
	customer_id,
    txn_month,
    SUM(CASE
		WHEN txn_type = 'deposit' THEN txn_amount
        WHEN txn_type = 'withdrawal' THEN - txn_amount
        WHEN txn_type = 'purchase' THEN - txn_amount
        END) AS monthly_account_balance
FROM cte_month
GROUP BY 1,2
ORDER BY 1;

-- Now, I need to carry the amounts over into the next month, by partitioning
WITH cte_month AS (
SELECT
	customer_id,
    MONTH(txn_date) AS txn_month,
    txn_type,
    txn_amount
FROM customer_transactions
ORDER BY 1,2 ),
cte_monthly AS (
SELECT
	customer_id,
    txn_month,
    SUM(CASE
		WHEN txn_type = 'deposit' THEN txn_amount
        WHEN txn_type = 'withdrawal' THEN - txn_amount
        WHEN txn_type = 'purchase' THEN - txn_amount
        END) AS monthly_account_balance
FROM cte_month
GROUP BY 1,2
ORDER BY 1 )

SELECT
	customer_id,
    txn_month,
    monthly_account_balance,
    SUM(monthly_account_balance) OVER (PARTITION BY customer_id ORDER BY txn_month) AS running_balance
FROM cte_monthly
GROUP BY 1,2,3
ORDER BY 1,2;

-- This solution gives the individual month's ending balance for each customer, as well as the total running balance between the months for each customer

 


