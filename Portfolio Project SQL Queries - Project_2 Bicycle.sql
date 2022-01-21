-- Bicycles Manufacturing Company in US
-- Product Category : Children Bicycle, Comfort Bicycle, Cruisers Bicycle, Cyclocross Bicycle, Electric Bikes, Mountain Bikes, Road Bikes
-- total 9 different brands

USE PortfolioProject.dbo.BicycleManufacturing;


-- SALES
-- ===============================================================================================

-- Total Sales and Sales Qty by each category within 3 years
SELECT 
    YEAR(o.order_date) AS sales_year,
    c.category_name AS category,
    SUM(odr.quantity) AS sales_qty,
    SUM(odr.list_price) - SUM(odr.discount) AS total_sales
FROM
    sales.orders o
        JOIN
    sales.order_items odr ON o.order_id = odr.order_id
        JOIN
    products p ON p.product_id = odr.product_id
        JOIN
    categories c ON c.category_id = p.category_id
GROUP BY sales_year , c.category_name
ORDER BY sales_year;


-- Total Sales breakdown per month per year
SELECT 
    YEAR(o.shipped_date) AS sales_year,
    MONTH(o.shipped_date) AS sales_month,
    ROUND(SUM(i.quantity * i.list_price * (1 - i.discount)),
            0) AS total_sales
FROM
    orders o
        JOIN
    order_items i ON o.order_id = i.order_id
GROUP BY YEAR(o.shipped_date) , MONTH(o.shipped_date)
ORDER BY YEAR(o.shipped_date) , MONTH(o.shipped_date);


-- stores by sales amount (start from highest sales store)
SELECT 
    s.store_id,
    s.store_name,
    s.city,
    s.state,
    ROUND(SUM(i.quantity * i.list_price * (1 - i.discount)),
            0) AS sales_amount
FROM
    orders o
        JOIN
    stores s ON o.store_id = s.store_id
        JOIN
    order_items i ON o.order_id = i.order_id
GROUP BY s.store_id
ORDER BY sales_amount DESC;


-- high performance sales staff by sales amount 
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    COUNT(DISTINCT o.order_id) AS total_invoice,
    ROUND(SUM(i.quantity * i.list_price * (1 - i.discount)),
            0) AS sales_amount
FROM
    orders o
        JOIN
    order_items i ON o.order_id = i.order_id
        JOIN
    staffs s ON s.staff_id = o.staff_id
GROUP BY o.staff_id
ORDER BY sales_amount DESC;


-- high performance sales staff by total invoice qty 
SELECT 
    s.staff_id,
    s.first_name,
    s.last_name,
    s.store_id,
    COUNT(o.order_id) AS total_order
FROM
    staffs s
        JOIN
    orders o ON s.staff_id = o.staff_id
GROUP BY staff_id
ORDER BY total_order DESC;


-- finding the products that have no sales across the stores
SELECT 
    s.store_id,
    p.product_id,
    p.product_name,
    p.category_id,
    p.model_year,
    IFNULL(sales, 0) AS sales
FROM
    stores s
        CROSS JOIN
    products p
        LEFT JOIN
    (SELECT 
        s.store_id,
            p.product_id,
            SUM(quantity * i.list_price) AS sales
    FROM
        orders o
    JOIN order_items i ON i.order_id = o.order_id
    JOIN stores s ON s.store_id = o.store_id
    JOIN products p ON p.product_id = i.product_id
    GROUP BY s.store_id , p.product_id) c ON c.store_id = s.store_id
        AND c.product_id = p.product_id
WHERE
    sales IS NULL
ORDER BY product_id , store_id;


-- finding high sales products across the stores
SELECT 
    s.store_id,
    p.product_id,
    p.product_name,
    p.model_year,
    SUM(i.quantity) AS sell_out_total_qty,
    SUM(i.quantity * i.list_price) AS sales
FROM
    orders o
        JOIN
    order_items i ON i.order_id = o.order_id
        JOIN
    stores s ON s.store_id = o.store_id
        JOIN
    products p ON p.product_id = i.product_id
GROUP BY s.store_id , p.product_id
ORDER BY sell_out_total_qty DESC;


-- ORDERS
-- ===============================================================================================

-- order status and quantity
SELECT 
    CASE order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
    END AS order_status,
    COUNT(order_id) AS order_count
FROM
    orders
WHERE
    YEAR(order_date) = 2018
GROUP BY order_status; 


-- classify sales order by order value with handling store and staff
SELECT 
    o.order_id,
    SUM(quantity * list_price) AS order_value,
    o.order_status,
    o.store_id,
    o.staff_id,
    CASE
        WHEN SUM(quantity * list_price) <= 500 THEN 'Very Low'
        WHEN
            SUM(quantity * list_price) > 500
                AND SUM(quantity * list_price) <= 1000
        THEN
            'Low'
        WHEN
            SUM(quantity * list_price) > 1000
                AND SUM(quantity * list_price) <= 5000
        THEN
            'Medium'
        WHEN
            SUM(quantity * list_price) > 5000
                AND SUM(quantity * list_price) <= 10000
        THEN
            'High'
        WHEN SUM(quantity * list_price) > 10000 THEN 'Very High'
    END order_priority
FROM
    orders o
        JOIN
    order_items i ON i.order_id = o.order_id
WHERE
    YEAR(order_date) = 2018
GROUP BY o.order_id;


-- sales orders with filter by location (customers located in New York)
SELECT 
    o.order_id,
    o.order_date,
    o.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state,
    c.zip_code
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
WHERE
    o.customer_id IN (SELECT 
            customer_id
        FROM
            customers
        WHERE
            city = 'New York')
ORDER BY o.order_date DESC;


-- current processing order list by invoice amount with descending order
SELECT 
    o.order_id,
    ROUND(SUM(i.quantity * i.list_price * (1 - i.discount)),
            2) AS total,
    o.order_status
FROM
    orders o
        JOIN
    order_items i ON o.order_id = i.order_id
GROUP BY order_id
HAVING o.order_status = 2
ORDER BY total DESC;


-- net value of every order during the year
SELECT 
    order_id,
    SUM(quantity * list_price * (1 - discount)) AS net_value
FROM
    order_items
GROUP BY order_id;


-- average invoice amount by year
SELECT 
    YEAR(o.order_date) AS year_sales,
    ROUND(AVG(i.quantity * i.list_price * (1 - i.discount)),
            2) AS avg_invoice_amount
FROM
    orders o
        JOIN
    order_items i ON o.order_id = i.order_id
GROUP BY year_sales;


-- CUSTOMERS
-- ===============================================================================================

-- top 50 customer list
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state,
    ROUND(SUM(i.quantity * i.list_price * (1 - i.discount)),
            2) AS total
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
        JOIN
    order_items i ON o.order_id = i.order_id
GROUP BY c.customer_id
ORDER BY total DESC
LIMIT 50;


-- customer list who placed at least two orders during the year
SELECT 
    o.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    YEAR(order_date),
    COUNT(order_id)
FROM
    orders o
        JOIN
    customers c ON c.customer_id = o.customer_id
WHERE
    YEAR(order_date) = 2018
GROUP BY o.customer_id , YEAR(order_date)
HAVING COUNT(order_id) >= 2
ORDER BY o.customer_id;


-- customers by region (location-based result)
SELECT 
    state, COUNT(customer_id) AS customer_count
FROM
    customers
GROUP BY state
ORDER BY customer_count DESC;


-- city and state of current customers 
SELECT 
    city, state, zip_code
FROM
    customers
GROUP BY city , state , zip_code
ORDER BY city , state , zip_code;


-- number of customers by city and state
SELECT 
    city, state, COUNT(customer_id) AS customer_count
FROM
    customers
GROUP BY state , city
ORDER BY customer_count DESC;


-- number of orders placed by the customer by year
SELECT 
    customer_id,
    YEAR(order_date) AS order_year,
    COUNT(order_id) AS order_placed
FROM
    orders
GROUP BY customer_id
ORDER BY order_year;


-- PRODUCTS
-- ===============================================================================================

-- product information and each price 
SELECT 
    p.product_name, c.category_name, p.list_price
FROM
    products p
        JOIN
    categories c ON p.category_id = c.category_id
ORDER BY p.product_name;


-- highest and lowest price of brands which produced in 2018
SELECT 
    brand_name,
    MIN(list_price) AS min_price,
    MAX(list_price) AS max_price
FROM
    products p
        JOIN
    brands b ON b.brand_id = p.brand_id
WHERE
    model_year = 2018
GROUP BY brand_name
ORDER BY brand_name;


-- average price by brands
SELECT 
    b.brand_id,
    b.brand_name,
    ROUND(AVG(p.list_price), 0) AS avg_price
FROM
    products p
        JOIN
    brands b ON b.brand_id = p.brand_id
WHERE
    model_year = 2018
GROUP BY brand_name
ORDER BY brand_name;


-- average price by brands according to model year
SELECT 
    p.model_year,
    b.brand_name,
    ROUND(AVG(p.list_price), 0) AS avg_price
FROM
    products p
        JOIN
    brands b ON b.brand_id = p.brand_id
GROUP BY b.brand_name , p.model_year
ORDER BY p.model_year;


-- average price of Strider and Trek (each product)
SELECT 
    product_name, list_price
FROM
    products
WHERE
    list_price > (SELECT 
            AVG(list_price)
        FROM
            products
        WHERE
            brand_id IN (SELECT 
                    brand_id
                FROM
                    brands
                WHERE
                    brand_name = 'Strider'
                        OR brand_name = 'Trek'))
ORDER BY list_price;


-- STOCK
-- ===============================================================================================

-- stock balance (month-end or year-end closing)
SELECT 
    p.product_id, p.product_name, s.quantity, st.store_id
FROM
    products p
        JOIN
    stocks s ON p.product_id = s.product_id
        JOIN
    stores st ON st.store_id = s.store_id
ORDER BY product_name , store_id;
-- 963 in list

SELECT 
    p.product_id, p.product_name, s.quantity, st.store_id
FROM
    products p
        CROSS JOIN
    stocks s ON p.product_id = s.product_id
        JOIN
    stores st ON st.store_id = s.store_id
WHERE
    s.quantity = 0
ORDER BY product_name , store_id;
-- 24 items are 0 


-- OTHERS
-- ===============================================================================================

-- calculate monthly salary for each staff
SELECT 
    staff_id,
    COALESCE(hourly_rate * 22 * 8,
            weekly_rate * 4,
            monthly_rate) AS monthly_salary
FROM
    salaries;
    
    
    