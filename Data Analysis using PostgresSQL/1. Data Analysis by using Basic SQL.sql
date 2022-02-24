-- Analysis the data by using Basic SQL

-- select the id, account_id, and occurred_at columns for all orders in the orders table
SELECT id,account_id,occurred_at FROM orders;

-- using LIMIT 
SELECT occurred_at,account_id,channel
FROM web_events
LIMIT 15;

-- 10 earliest orders in the orders 
SELECT id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at
LIMIT 10;

-- Use the web_events table to find all information regarding individuals who were contacted via the channel of organic or adwords
SELECT * FROM web_events
WHERE channel IN ('organic','adwords');

-- top 5 orders in terms of largest total_amt_usd
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 5;

-- the lowest 20 orders in terms of smallest total_amt_usd
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd
LIMIT 20;

-- total order amount for all the orders, sorted first by the account ID (in ascending order), and then by the total dollar amount (in descending order)
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id,total_amt_usd DESC;

-- total order amount for each order, but this time sorted first by total dollar amount (in descending order), and then by account ID (in ascending order)
SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id;

/*Compare the results of these two queries above. How are the results different when you switch the column you sort on first*/
/*Ans:In query #1, all of the orders for each account ID are grouped together, and then within each of those groupings, the orders appear from the greatest order amount to the least. In query #2, since you sorted by the total dollar amount first, the orders appear from greatest to least regardless of which account ID they were from. Then they are sorted by account ID next. (The secondary sorting by account ID is difficult to see here, since only if there were two orders with equal total dollar amounts would there need to be any sorting by account ID.)*/

-- order greater than or equal to 1000
SELECT *
FROM orders
WHERE gloss_amt_usd > 1000
LIMIT 5;

-- orders table that have a total_amt_usd less than 500
SELECT *
FROM orders
WHERE total_amt_usd < 500
LIMIT 10;

-- Filter the accounts table to include the company name, website, and the primary point of contact (primary_poc) just for the Exxon Mobil company in the accounts table
SELECT name,website,primary_poc
FROM accounts
WHERE name LIKE 'Exxon Mobil';

-- Create a column that divides the standard_amt_usd by the standard_qty to find the unit price for standard paper for each order. Limit the results to the first 10 orders
SELECT id,account_id,ROUND(standard_amt_usd/standard_qty,2) AS unit_price
FROM orders
LIMIT 10;

-- finding the percentage of revenue that comes from each order
SELECT id, account_id, 
   poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS post_per
FROM orders
LIMIT 10;

-- All the companies whose names start with 'C'
SELECT * FROM accounts
WHERE name LIKE 'C%';

-- All companies whose names contain the string 'one' in name
SELECT * FROM accounts
WHERE name LIKE '%one%';

-- All companies whose names end with 's'
SELECT * FROM accounts
WHERE name LIKE '%s';

-- finding accounts data for Walmart, Target, and Nordstrom
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart','Target','Nordstrom');

-- finding all information regarding individuals who were contacted via the channel of organic or adwords
SELECT * FROM web_events
WHERE channel IN ('organic','adwords');

-- finding accounts data except Walmart, Target, and Nordstrom
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart','Target','Nordstrom');

-- finding individuals who were contacted via any method except using organic or adwords methods
SELECT * FROM web_events
WHERE channel NOT IN ('organic','adwords');

-- all the orders where the standard_qty is over 1000
SELECT * FROM orders
WHERE standard_qty > 100
AND poster_qty = 0
AND gloss_qty = 0;

-- finding order with gloss quantity with qty
SELECT * FROM orders
WHERE gloss_qty BETWEEN 24 AND 29;

-- individuals who were contacted via the organic or adwords channels, sorted from newest to oldest
SELECT * FROM web_events
WHERE channel IN ('organic','adwords')
AND occurred_at BETWTEEN '2016-01-01' AND occurred_at '2016-12-31'
ORDER BY occurred_at DESC;

-- list of orders ids where either gloss_qty or poster_qty is greater than 4000
SELECT id FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

-- list of orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000
SELECT * FROM orders
WHERE standard_qty > 0 AND
	(gloss_qty > 1000 OR poster_qty > 1000);
	
-- company names that start with a 'C' or 'W', and the primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'
SELECT name FROM accounts
WHERE (name lIKE 'C%' OR name LIKE 'W%')
	AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
		AND primary_poc NOT LIKE '%eana%');