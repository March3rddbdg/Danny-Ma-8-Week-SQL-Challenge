/*

DANNY MA 8 WEEK SQL CHALLENGE: WEEK 3 - FOODIE-FI

INTRODUCTION/CUSTOMER JOURNEY

*/

-- 1. Based off of 8 sample customers (1, 2, 11, 13, 15, 16, 18, 19) from subscriptions table, write a brief description about each customer's journey.

-- Customer 1:
SELECT
	*
FROM subscriptions AS sub
	INNER JOIN plans 
		ON sub.plan_id = plans.plan_id
WHERE customer_id = 1;
-- Customer 1 downgraded from the automated transition to pro-monthly after the free trial phase to the basic monthly subsciption for $9.90
-- It's only a monthly subscription at this stage.

-- Customer 2:
SELECT
	*
FROM subscriptions AS sub
	INNER JOIN plans 
		ON sub.plan_id = plans.plan_id
WHERE customer_id = 2;
-- Like customer 1, customer 2 kept the subscription after the free trial phase.
-- Customer 2 really loved the service, because they purchased the pro annual subsciption for $199.00.

-- Customer 11:
SELECT
	*
FROM subscriptions AS sub
	INNER JOIN plans 
		ON sub.plan_id = plans.plan_id
WHERE customer_id = 11;
-- Customer 11 cancelled the service after the 1 week free trial phase.
-- They apparently did not see a need for paying for this service at all, or didn't like it enough to pay for it.

-- Customer 13:
SELECT
	*
FROM subscriptions AS sub
	INNER JOIN plans 
		ON sub.plan_id = plans.plan_id
WHERE customer_id = 13;
-- Customer 13 chose to downgrade to basic monthly following the free trial phase - they opted not to do the automated pro monthly after the week's free trial
-- After having the basic monthly subsciption for about 3 months, this customer decided to upgrade to pro monthly - they must have been enjoying it!
-- With pro, they have unlimited viewing and can download videos for offline viewing.

-- Customer 15:
SELECT
	*
FROM subscriptions AS sub
	INNER JOIN plans 
		ON sub.plan_id = plans.plan_id
WHERE customer_id = 15;
-- This customer allowed the automated switch from free trial to pro monthly after the free week.
-- After one month of pro monthly, this customer ultimately cancelled the subsciption entirely.
-- They must not have found any use from it, they decided to cancel versus downgrade.

-- Customer 16:
SELECT
	*
FROM subscriptions AS sub
	INNER JOIN plans 
		ON sub.plan_id = plans.plan_id
WHERE customer_id = 16;
-- This customer opted to downgrade from the automated switch to pro monthly after the free week.
-- They must have enjoyed the service and wanted more unlimited content, because after about 4 months, they upgraded to the pro annual subscription.
-- They plan on using it for a whole year!

-- Customer 18:
SELECT
	*
FROM subscriptions AS sub
	INNER JOIN plans 
		ON sub.plan_id = plans.plan_id
WHERE customer_id = 18;
-- This customer allowed the automated progression from free trial to pro monthly after the week.
-- They haven't made any alterations since.

-- Customer 19:
SELECT
	*
FROM subscriptions AS sub
	INNER JOIN plans 
		ON sub.plan_id = plans.plan_id
WHERE customer_id = 19;
-- This customer also allowed the automated progression from free week to pro monthly.
-- After 2 months of the pro monthly, they upgraded to the pro annual. They must have been enjoying the service and knew they'd use it for the whole year!



