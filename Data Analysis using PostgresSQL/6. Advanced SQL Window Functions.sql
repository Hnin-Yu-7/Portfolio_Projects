-- [Advanced]SQL Window Functions

SELECT  standard_qty,
	DATE_TRUNC('month',occurred_at) AS month,
	SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month',occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;


/*create a running total of standard_amt_usd (in the orders table) over order time with no date truncation.*/
SELECT standard_amt_usd, 
	SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders


/*create a running total of standard_amt_usd (in the orders table) over order time, 
with, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable.*/
SELECT standard_amt_usd, 
	DATE_TRUNC('year',occurred_at) AS year,
	SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year',occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

-- ============================================================================

-- Ranking Total Paper Ordered by Account from hightest to loweest by using a partition
SELECT id, account_id, total,
	RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders;


SELECT id,
		account_id,
		standard_qty,
		DATE_TRUNC('month',occurred_at) AS month,
		DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
		SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_standard_qty,
		COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_standard_aty,
		AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS  average_standard_qty,
		MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_standard_qty,
		MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_standard_qty
FROM orders;


-- =========================================================================================================

/*-------------- Window Aliases -----------------*/

SELECT id,
		account_id,
		standard_qty,
		DATE_TRUNC('month',occurred_at) AS month,
		DENSE_RANK() OVER main_window AS dense_rank,
		SUM(standard_qty) OVER main_window AS sum_standard_qty,
		COUNT(standard_qty) OVER main_window AS count_standard_aty,
		AVG(standard_qty) OVER main_window AS  average_standard_qty,
		MIN(standard_qty) OVER main_window AS min_standard_qty,
		MAX(standard_qty) OVER main_window AS max_standard_qty
FROM orders
WINDOW main_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at))


SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))


-- ========================================================================================================================

/* ----------------- LEAD and LAG  ------------------------*/

/*LAG */
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference
FROM (
       SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders 
       GROUP BY 1
      ) sub


/* LELAD */
SELECT account_id,
       standard_sum,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders 
       GROUP BY 1
     ) sub
	 
	 
/*determine how the current order's total revenue 
compares to the next order's total revenue.*/

SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders 
 GROUP BY 1
 ) sub
 

-- =================================================================================================================

 /* Percentile */
 
SELECT id, account_id, occurred_at,standard_qty,
	NTILE(4) OVER (ORDER BY standard_qty) AS quartile,
	NTILE(5) OVER (ORDER BY standard_qty) AS quintile,
	NTILE(100) OVER (ORDER BY standard_qty) AS percentile
FROM orders
ORDER BY standard_qty DESC;


-- divide the accounts into 4 levels in terms of the amount of standard_qty 
SELECT account_id, occurred_at,standard_qty,
	NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY account_id DESC;


-- divide the accounts into two levels in terms of the amount of gloss_qty 
SELECT account_id, occurred_at,gloss_qty,
	NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM orders
ORDER BY account_id DESC;


/*Use the NTILE functionality to divide the orders for each account into 100 levels 
in terms of the amount of total_amt_usd for their orders.*/
SELECT account_id, occurred_at,total_amt_usd,
	NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY account_id DESC;


