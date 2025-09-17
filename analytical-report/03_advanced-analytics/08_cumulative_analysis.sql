/*
===============================================================================
-- Cumulative Analysis (Expanded Edition)
===============================================================================
Purpose:
    - To calculate running totals (cumulative sums) and moving averages for key metrics.
    - To track how metrics accumulate over time, which is essential for understanding
      growth, momentum, and long-term trends.
    - This analysis is vital for reports showing Year-to-Date (YTD) performance,
      cumulative customer growth, and smoothed-out trend lines.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER(), COUNT() OVER(), ROW_NUMBER() OVER()
    - Common Table Expressions (CTEs) for better readability.
    - Date Functions: DATETRUNC() for grouping by time periods.
===============================================================================
*/

-- ==============================================================================
-- Section 1: Monthly Running Total and Moving Average (Enhanced from Original)
-- This query calculates the cumulative sales and a simple moving average of price over time.
-- The original query was corrected to aggregate by month, which is more practical for
-- tracking cumulative performance than by year.
-- ==============================================================================

-- First, we use a Common Table Expression (CTE) to pre-aggregate the sales data by month.
-- This makes the main query cleaner and easier to read.
WITH MonthlyMetrics AS (
    SELECT 
        -- Truncate the date to the beginning of the month (e.g., '2025-09-17' becomes '2025-09-01').
        DATETRUNC(month, order_date) AS order_month,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM 
        gold.fact_sales
    WHERE 
        order_date IS NOT NULL -- Always a good practice to filter out null dates.
    GROUP BY 
        DATETRUNC(month, order_date)
)
-- Now, we query the CTE to apply window functions.
SELECT
	order_month,
	total_sales,
	
	-- Calculate the running total of sales.
	-- The SUM() OVER () clause sums up 'total_sales' for the current row and all preceding rows,
	-- ordered chronologically by 'order_month'.
	SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales,
	
	-- Calculate the moving average of the average price.
	-- This calculates the average of 'avg_price' from the first month up to the current month.
	-- It helps to see the trend of the average price over the entire history.
	AVG(avg_price) OVER (ORDER BY order_month) AS overall_moving_average_price
FROM
	MonthlyMetrics
ORDER BY
    order_month;

-- ==============================================================================
-- Section 2: Additional and More Advanced Cumulative Analysis Queries
-- These queries answer more specific business questions using your tables.
-- ==============================================================================

-- Ques 1: What is the Year-to-Date (YTD) cumulative sales for each month?
-- This is a very common business report. The running total should reset at the beginning of each year.
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
    -- The PARTITION BY YEAR(order_month) clause is the key here.
    -- It divides the data into "partitions" for each year, and the SUM() calculation
    -- resets to zero at the start of each new partition (i.e., each new year).
    SUM(total_sales) OVER (PARTITION BY YEAR(order_month) ORDER BY order_month) AS ytd_cumulative_sales
FROM
    MonthlySales
ORDER BY
    order_month;


-- Ques 2: How has our customer base grown over time? (Cumulative Customer Acquisition)
-- This query tracks the cumulative number of unique customers who have made a purchase.
WITH FirstOrderDates AS (
    -- First, find the very first order date for each unique customer.
    SELECT
        customer_key,
        MIN(order_date) as first_order_date
    FROM
        gold.fact_sales
    GROUP BY
        customer_key
)
SELECT
    -- Truncate the first order date to the month to see monthly new customer cohorts.
    DATETRUNC(month, first_order_date) as acquisition_month,
    -- Count how many new customers we acquired this month.
    COUNT(customer_key) as new_customers_this_month,
    -- Calculate the cumulative sum of all customers acquired up to and including this month.
    SUM(COUNT(customer_key)) OVER (ORDER BY DATETRUNC(month, first_order_date)) as cumulative_total_customers
FROM
    FirstOrderDates
GROUP BY
    DATETRUNC(month, first_order_date)
ORDER BY
    acquisition_month;


-- Ques 3: What is the cumulative sales contribution of each product category over time?
-- This helps identify which categories have been historically strong performers.
WITH MonthlyCategorySales AS (
    SELECT
        DATETRUNC(month, f.order_date) AS order_month,
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM 
        gold.fact_sales f
    LEFT JOIN 
        gold.dim_products p ON f.product_key = p.product_key
    WHERE 
        p.category IS NOT NULL
    GROUP BY 
        DATETRUNC(month, f.order_date), p.category
)
SELECT
    order_month,
    category,
    total_sales,
    -- Here, we partition by 'category'. This creates a separate running total for each product category.
    -- This shows how sales for a single category, like 'Bikes' or 'Clothing', have accumulated over time.
    SUM(total_sales) OVER (PARTITION BY category ORDER BY order_month) AS running_sales_by_category
FROM
    MonthlyCategorySales
ORDER BY
    category, order_month;


-- Ques 4: What is the rolling 3-month moving average of sales?
-- A rolling average is more responsive to recent trends than an overall average.
-- It smooths out short-term noise to reveal the underlying trend.
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
    -- 'ROWS BETWEEN 2 PRECEDING AND CURRENT ROW' defines a "frame" for the average calculation.
    -- For each month, it averages the sales of that month and the two previous months.
    -- This provides a much better view of recent performance trends.
    AVG(total_sales) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_avg_sales
FROM
    MonthlySales
ORDER BY
    order_month;
