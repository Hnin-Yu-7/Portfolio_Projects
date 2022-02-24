-- Analyzing data by using SQL Joins

-- pulling all the data from the accounts table, and all the data from the orders table
SELECT accounts.*, orders.*
FROM accounts
JOIN orders ON accounts.id = accounts.id;

-- pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website and the primary_poc from the accounts table
SELECT orders.standard_qty, orders.gloss_qty, 
       orders.poster_qty,  accounts.website, 
       accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id

-- all web_events associated with account name of Walmart
SELECT name, primary_poc, occurred_at, channel
FROM accounts
JOIN web_events ON accounts.id = web_events.account_id
WHERE accounts.name LIKE '%Walmart%';

-- region for each sales_rep along with their associated accounts
SELECT region.name AS region_name, sales_reps.name AS sales_rep_name, accounts.name AS account_name
FROM region
JOIN sales_reps ON region.id = sales_reps.region_id
JOIN accounts ON accounts.sales_rep_id = sales_reps.id
ORDER BY 3;

-- name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order
SELECT orders.id,region.name AS region_name, accounts.name AS account_name,(total_amt_usd/total+0.01) AS unit_price
FROM orders
JOIN accounts ON orders.account_id = accounts.id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
JOIN region ON region.id = sales_reps.region_id;

/*--------------------------------------------*/

-- region for each sales_rep along with their associated accounts. (only for the Midwest region)
SELECT region.name AS region_name, sales_reps.name AS sales_rep_name, accounts.name AS account_name
FROM region
JOIN sales_reps ON region.id = sales_reps.region_id
JOIN accounts ON accounts.sales_rep_id = sales_reps.id
WHERE region.name LIKE 'Midwest'
ORDER BY 3;

-- the region for each sales_rep along with their associated accounts where sales rep has a first name starting with S and in the Midwest region
SELECT region.name AS region_name, sales_reps.name AS sales_rep_name, accounts.name AS account_name
FROM region
JOIN sales_reps ON region.id = sales_reps.region_id
JOIN accounts ON accounts.sales_rep_id = sales_reps.id
WHERE region.name LIKE 'Midwest'
	AND LOWER(sales_reps.name) LIKE 's%'
ORDER BY 3;

-- region list of every order, including account name and the unit price they paid (total_amt_usd/total) for the order
SELECT orders.id,region.name AS region_name, accounts.name AS account_name,total_amt_usd/(total+0.01) AS unit_price
FROM orders
JOIN accounts ON orders.account_id = accounts.id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
JOIN region ON region.id = sales_reps.region_id
WHERE standard_qty > 100;


-- total order information by each region by filtering standard order quantity exceeds 100 and 50
SELECT orders.id,region.name AS region_name, accounts.name AS account_name,total_amt_usd/(total+0.01) AS unit_price
FROM orders
JOIN accounts ON orders.account_id = accounts.id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
JOIN region ON region.id = sales_reps.region_id
WHERE standard_qty > 100
	AND poster_qty > 50
ORDER BY unit_price;


SELECT orders.id,region.name AS region_name, accounts.name AS account_name,total_amt_usd/(total+0.01) AS unit_price
FROM orders
JOIN accounts ON orders.account_id = accounts.id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
JOIN region ON region.id = sales_reps.region_id
WHERE standard_qty > 100
	AND poster_qty > 50
ORDER BY unit_price DESC;

-- What are the different channels used by account id 1001
SELECT DISTINCT accounts.name, web_events.channel
FROM accounts
JOIN web_events ON accounts.id = web_events.account_id
WHERE accounts.id = 1001;

-- Finding all the orders that occurred in 2015
SELECT occurred_at, accounts.name AS account_name, total AS order_total, total_amt_usd
FROM orders
JOIN accounts ON accounts.id = orders.account_id
WHERE occurred_at BETWEEN '2015-01-01' AND '2016-01-01'
ORDER BY occurred_at DESC;


