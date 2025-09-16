/*
===============================================================================
-- Change Over Time Analysis (Expanded Edition)
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality (e.g., monthly, quarterly).
    - To measure growth or decline over specific periods using comparative analysis.

SQL Functions Used:
    - Date Functions: YEAR(), MONTH(), DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - Window Functions: LAG(), SUM() OVER (...), AVG() OVER (...) for advanced analysis.
    - Common Table Expressions (CTEs): WITH ... AS () to structure complex queries.
===============================================================================
*/

-- ==============================================================================
-- Section 1: Foundational Time-Based Aggregations (Rewritten from Original)
-- These queries demonstrate different methods to group transactional data by month.
-- ==============================================================================

-- Query 1.1: Using YEAR() and MONTH() functions
-- This is a straightforward and highly readable method for grouping by month.
-- It extracts the integer value for the year and month from the date column.
SELECT
    YEAR(order_date) AS order_year, -- Extracts the year part of the date (e.g., 2025)
    MONTH(order_date) AS order_month, -- Extracts the month part of the date (e.g., 9 for September)
    
    -- Aggregate Metrics
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM 
    gold.fact_sales
WHERE 
    order_date IS NOT NULL -- Best practice: filter out any null dates to avoid errors.
GROUP BY 
    YEAR(order_date), MONTH(order_date) -- Group results for each unique year/month combination.
ORDER BY 
    YEAR(order_date), MONTH(order_date); -- Order chronologically to see the trend over time.

-- Query 1.2: Using DATETRUNC() function
-- DATETRUNC is powerful because it "truncates" a date to a specified part, returning a proper date type.
-- For example, '2025-09-17' becomes '2025-09-01' when truncated to the month.
-- This is excellent for charting tools that require a date axis.
SELECT
    DATETRUNC(month, order_date) AS order_month_start, -- Returns the first day of the month for each order date.
    
    -- Aggregate Metrics
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM 
    gold.fact_sales
WHERE 
    order_date IS NOT NULL
GROUP BY 
    DATETRUNC(month, order_date) -- Grouping by the first day of the month effectively groups by month.
ORDER BY 
    order_month_start; -- The result is a proper date, so sorting is simple and accurate.

-- Query 1.3: Using FORMAT() function
-- FORMAT is used for display purposes, converting a date into a custom string.
-- While good for reporting, be aware that it returns a string, which can affect sorting if not formatted carefully.
-- 'yyyy-MMM' format (e.g., '2025-Sep') sorts correctly because the year comes first.
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS formatted_order_month, -- Formats the date as a string like '2025-Sep'.
    
    -- Aggregate Metrics
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM 
    gold.fact_sales
WHERE 
    order_date IS NOT NULL
GROUP BY 
    FORMAT(order_date, 'yyyy-MMM')
ORDER BY 
    MIN(order_date); -- It's safer to order by the actual min date in the group rather than the formatted string.


-- ==============================================================================
-- Section 2: Additional and More Advanced Time-Series Queries
-- These queries build on the foundation to answer more complex business questions.
-- ==============================================================================

-- Ques 1: What is the sales performance by quarter?
-- This helps analyze performance based on common business cycles.
SELECT
    YEAR(order_date) AS order_year,
    DATEPART(quarter, order_date) AS order_quarter, -- DATEPART is another way to extract a specific part of a date.
    SUM(sales_amount) AS total_sales,
    AVG(sales_amount) AS average_sale_per_order
FROM 
    gold.fact_sales
GROUP BY 
    YEAR(order_date),
    DATEPART(quarter, order_date)
ORDER BY
    order_year,
    order_quarter;


-- Ques 2: Is there a weekly pattern? Analyze sales by Day of the Week.
-- This is useful for identifying peak business days for staffing, marketing, or promotions.
SELECT
    DATEPART(weekday, order_date) AS weekday_number, -- Returns a number representing the day (e.g., 1 for Sunday, 2 for Monday)
    FORMAT(order_date, 'dddd') AS weekday_name, -- 'dddd' format code gives the full day name (e.g., 'Wednesday')
    SUM(quantity) AS total_items_sold,
    COUNT(DISTINCT order_number) AS total_orders
FROM
    gold.fact_sales
GROUP BY
    DATEPART(weekday, order_date),
    FORMAT(order_date, 'dddd')
ORDER BY
    weekday_number;


-- Ques 3: What is the Month-over-Month (MoM) sales growth percentage?
-- This is a key metric for measuring business momentum. We use a CTE and the LAG() window function.
WITH MonthlySales AS (
    -- First, create a temporary result set (CTE) with sales aggregated by month.
    SELECT
        DATETRUNC(month, order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM
        gold.fact_sales
    GROUP BY
        DATETRUNC(month, order_date)
)
SELECT
    order_month,
    total_sales,
    -- LAG() function retrieves the 'total_sales' value from the previous row, ordered by month.
    LAG(total_sales, 1) OVER (ORDER BY order_month) AS previous_month_sales,
    -- Calculate the growth percentage. Use NULLIF to avoid division-by-zero errors.
    (total_sales - LAG(total_sales, 1) OVER (ORDER BY order_month)) * 100.0 / NULLIF(LAG(total_sales, 1) OVER (ORDER BY order_month), 0) AS mom_growth_percentage
FROM
    MonthlySales
ORDER BY
    order_month;


-- Ques 4: What is the 3-month moving average of sales?
-- Moving averages help smooth out short-term fluctuations to identify longer-term trends.
WITH MonthlySales AS (
    -- We use the same CTE as the previous query to get monthly sales.
    SELECT
        DATETRUNC(month, order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM
        gold.fact_sales
    GROUP BY
        DATETRUNC(month, order_date)
)
SELECT
    order_month,
    total_sales,
    -- Use the AVG() window function to calculate the average over a specific "window" of rows.
    -- 'ROWS BETWEEN 2 PRECEDING AND CURRENT ROW' defines the window as the current month and the two before it.
    AVG(total_sales) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS three_month_moving_avg
FROM
    MonthlySales
ORDER BY
    order_month;


-- Ques 5: What is the cumulative Year-to-Date (YTD) sales for each month?
-- YTD is a common metric for tracking progress towards annual goals.
WITH MonthlySales AS (
    SELECT
        DATETRUNC(month, order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM
        gold.fact_sales
    GROUP BY
        DATETRUNC(month, order_date)
)
SELECT
    order_month,
    total_sales,
    -- SUM() as a window function calculates a running total.
    -- 'PARTITION BY YEAR(order_month)' tells the function to restart the sum for each new year.
    SUM(total_sales) OVER (PARTITION BY YEAR(order_month) ORDER BY order_month) AS ytd_cumulative_sales
FROM
    MonthlySales
ORDER BY
    order_month;