
-- SQL Aggregations

-- finding 3 different levels of customers based on their purhcase amount
/*The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. 
The second level is between 200,000 and 100,000 usd. 
The lowest level is anyone under 100,000 usd.*/
SELECT accounts.name,SUM(total_amt_usd) AS total_sales_of_all_orders,
	CASE
		WHEN SUM(total_amt_usd) > 200000 THEN 'Top'
		WHEN SUM(total_amt_usd) >= 200000 AND SUM(total_amt_usd) <= 100000 THEN 'Middle'
		ELSE 'Low'
	END AS customer_level
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY 2 DESC;


/*similar calculation to the above,
but to obtain the total amount spent by customers only in 2016 and 2017. 
Keep the same levels as in the above. Order with the top spending customers listed first.*/
SELECT accounts.name,SUM(total_amt_usd) AS total_sales_of_all_orders,
	CASE
		WHEN SUM(total_amt_usd) > 200000 THEN 'Top'
		WHEN SUM(total_amt_usd) >= 200000 AND SUM(total_amt_usd) <= 100000 THEN 'Middle'
		ELSE 'Low'
	END AS customer_level
FROM accounts
JOIN orders ON accounts.id = orders.account_id
WHERE DATE_PART('year',occurred_at) BETWEEN 2016 AND 2017
GROUP BY accounts.id
ORDER BY 2 DESC;

/*version 2*/
SELECT a.name, SUM(total_amt_usd) total_spent, 
     CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
     WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
     ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31' 
GROUP BY 1
ORDER BY 2 DESC;


-- identifying top performing sales reps, which are sales reps associated with more than 200 orders
SELECT sales_reps.name, COUNT(*) AS total_number_of_orders,
	CASE
		WHEN SUM(total) > 200 THEN 'Top'
		ElSE 'normal' 
	END AS sales_rep_performance_level
FROM orders
JOIN accounts ON accounts.id = orders.account_id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
GROUP BY 1
ORDER BY 2 DESC;

/*The previous didn't account for the middle, nor the dollar amount associated with the sales. 
Management decides they want to see these characteristics represented as well. 
We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders 
or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales*/
SELECT sales_reps.name, COUNT(*), SUM(total_amt_usd) total_spent, 
     CASE WHEN COUNT(*) > 200 OR SUM(total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS sales_rep_level
FROM orders
JOIN accounts ON accounts.id = orders.account_id 
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
GROUP BY sales_reps.name
ORDER BY 3 DESC;


-- Writing a query for each order, the account ID, total amount of the order, and the level of the order - ‘Large’ or ’Small’
-- depending on if the order is $3000 or more, or smaller than $3000
SELECT account_id, total_amt_usd,
	CASE
		WHEN total_amt_usd > 3000 THEN 'Large'
		ELSE 'Small'
	END
FROM orders;


-- the number of orders in each of three categories, based on the total number of items in each order. 
-- The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'
SELECT
	CASE
		WHEN total >= 2000 THEN 'At Least 2000'
		WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
		ELSE 'Less than 1000'
	END AS order_category,
	COUNT(*) AS number_of_orders
FROM orders
GROUP BY 1;




-- total sales in usd for each account
and the company name.*/
SELECT name,SUM(total_amt_usd) AS total_sales
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY name;

-- average amount spent per order on each paper type
SELECT AVG(standard_qty) AS avg_standard_qty, AVG(gloss_qty) AS avg_gloss_qty, AVG(poster_qty) AS avg_poster_qty, 
		AVG(standard_amt_usd) AS avg_standard_amt_usd, AVG(gloss_amt_usd) AS avg_gloss_amt_usd,AVG(poster_amt_usd) AS avg_poster_amt_usd
FROM orders;

SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT ((SELECT COUNT(*) FROM orders)/2)) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;

-- the most recent (latest) info
SELECT occurred_at, channel, name AS account_name
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
ORDER BY occurred_at DESC
LIMIT 1;


-- total number of times each type of channel from events
SELECT channel,COUNT(*) AS total_number_of_times
FROM web_events
GROUP BY channel
ORDER BY total_number_of_times DESC;

-- Who was the Sales Rep associated with the earliest web_event
SELECT occurred_at, sales_reps.name AS sales_rep_name
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
ORDER BY occurred_at
LIMIT 1;

-- Who was the primary contact associated with the earliest web_event
SELECT occurred_at, primary_poc
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
ORDER BY occurred_at
LIMIT 1;

-- What was the smallest order placed by each account in terms of total usd
SELECT name,MIN(total_amt_usd) AS smalled_order_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY name
ORDER BY smalled_order_amount;

-- Find the number of sales reps in each region
SELECT region.name AS region_name ,COUNT(*) AS number_of_sales_reps
FROM region
JOIN sales_reps ON region.id = sales_reps.region_id
GROUP BY region_name
ORDER BY number_of_sales_reps;

-- For each account, determining the average amount of each type of paper they purchased across their orders 
SELECT accounts.name AS account_name, AVG(standard_qty) AS avg_standard_qty,AVG(gloss_qty) AS avg_gloss_qty,AVG(poster_qty) AS avg_poster_qty
FROM orders
JOIN accounts ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY account_name;

-- determine the average amount spent per order on each paper type by sales accounts
SELECT accounts.name AS account_name, AVG(standard_amt_usd) AS avg_standard_amt_usd,AVG(gloss_amt_usd) AS avg_gloss_amt_usd,AVG(poster_amt_usd) AS avg_poster_amt_usd
FROM orders
JOIN accounts ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY account_name;


-- number of times a particular channel was used in the web_events table for each sales rep
SELECT sales_reps.name AS sales_rep_name, channel, COUNT(*) AS total_number_of_channel_usage
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
GROUP BY sales_rep_name,channel
ORDER BY total_number_of_channel_usage DESC;


-- number of times a particular channel was used in the web_events table for each region
SELECT region.name AS region_name, channel, COUNT(*) AS total_occurances
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
JOIN region ON region.id = sales_reps.region_id
GROUP BY region_name,channel
ORDER BY total_occurances DESC;



-- testing if there are any accounts associated with more than one region by using Distinct

SELECT a.id as "account id", r.id as "region id", 
a.name as "account name", r.name as "region name"
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;

/*and*/

SELECT DISTINCT id, name
FROM accounts;

-- sales reps worked on more than one account
SELECT sales_reps.id, sales_reps.name, COUNT(*) number_of_accounts
FROM accounts
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
GROUP BY 1,2
ORDER BY number_of_accounts;

-- How many of the sales reps have more than 5 accounts that they manage
SELECT sales_reps.name AS sales_rep_name, COUNT(sales_reps.name) AS number_of_managed_accounts
FROM sales_reps
JOIN accounts ON accounts.sales_rep_id = sales_reps.id
GROUP BY sales_rep_name
HAVING COUNT(sales_reps.name) > 5
ORDER BY number_of_managed_accounts DESC;

-- How many accounts have more than 20 orders
SELECT accounts.name AS account_name, COUNT(*) AS number_of_orders
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
HAVING COUNT(*) > 20
ORDER BY 1;

-- most order account
SELECT accounts.name AS account_name, COUNT(*) AS number_of_orders
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY number_of_orders DESC;


-- finding accounts spent more than 30,000 usd total across all orders
SELECT accounts.name AS account_name, SUM(total_amt_usd) AS total_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
HAVING SUM(total_amt_usd) > 30000
ORDER BY total_amount DESC;

-- finding accounts spent less than 1,000 usd total across all orders
SELECT accounts.name AS account_name, SUM(total_amt_usd) AS total_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
HAVING SUM(total_amt_usd) < 1000
ORDER BY total_amount;

-- Which account has spent the most with us
SELECT accounts.name AS account_name, SUM(total_amt_usd) AS total_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY total_amount DESC
LIMIT 1;

-- Which account has spent the least with us
SELECT accounts.name AS account_name, SUM(total_amt_usd) AS total_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY total_amount
LIMIT 1;

-- Which accounts used facebook as a channel to contact customers more than 6 times
SELECT accounts.name, channel, COUNT(*) AS total_usage
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
WHERE channel LIKE 'facebook'
GROUP BY accounts.id, channel
HAVING COUNT(*) > 6
ORDER BY total_usage DESC;

-- Which account used facebook most as a channel
SELECT accounts.name, channel, COUNT(*) AS total_usage
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
WHERE channel LIKE 'facebook'
GROUP BY accounts.id, channel
ORDER BY total_usage DESC
LIMIT 1;

-- Which channel was most frequently used by most accounts
SELECT channel, COUNT(*) AS total_usage
FROM web_events
GROUP BY channel
ORDER BY total_usage DESC
LIMIT 1;

-- Which channel was most frequently used by most accounts
SELECT accounts.name, channel, COUNT(*) AS total_usage
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
GROUP BY accounts.id, channel
ORDER BY total_usage DESC;


-- sales total in each year, order by greatest to least
SELECT DATE_PART('year',occurred_at) AS sales_year , SUM(total_amt_usd) AS yearly_total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;


-- the greatest sales month in terms of total
SELECT DATE_PART('month',occurred_at) AS sales_year , SUM(total_amt_usd) AS yearly_total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;


-- highest sales year in terms of total
SELECT DATE_PART('year',occurred_at) AS sales_year , COUNT(*) AS total_number_of_orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC;


-- month and year that Walmart spend the most on gloss paper in amount
SELECT DATE_TRUNC('month',occurred_at) AS month_of_sale_date,
	SUM(gloss_amt_usd) AS total_spent
FROM orders
JOIN accounts ON accounts.id = orders.account_id
WHERE accounts.name LIKE 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


