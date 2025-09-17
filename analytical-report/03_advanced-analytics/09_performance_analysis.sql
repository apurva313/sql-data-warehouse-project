/*
===============================================================================
-- Performance Analysis (Expanded Edition)
===============================================================================
Purpose:
    - To measure and compare performance over different time periods (e.g., Year-over-Year,
      Month-over-Month).
    - To benchmark entities (like products, categories, or customer segments) against
      their own historical performance or against averages.
    - To identify growth trends, declines, and seasonality, which are critical for
      strategic business decisions.

SQL Functions Used:
    - Window Functions: LAG() to access previous period's data, AVG() OVER() to calculate
      partitioned averages, DENSE_RANK() OVER() for ranking.
    - Common Table Expressions (CTEs): To break down complex logic into readable steps.
    - CASE Statements: To apply conditional logic for categorizing performance changes.
===============================================================================
*/

-- ==============================================================================
-- Section 1: Yearly Product Performance Analysis (Enhanced from Original)
-- This query analyzes the annual sales of each product, comparing it to two benchmarks:
-- 1. The product's own average annual sales across all years.
-- 2. The product's sales from the immediately preceding year (Year-over-Year).
-- ==============================================================================

-- A Common Table Expression (CTE) is used to first aggregate sales by product and year.
-- This simplifies the main query and improves readability.
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM
        gold.fact_sales f
    LEFT JOIN
        gold.dim_products p ON f.product_key = p.product_key
    WHERE
        f.order_date IS NOT NULL AND p.product_name IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_name
)
-- The main query uses window functions on the pre-aggregated data from the CTE.
SELECT
    order_year,
    product_name,
    current_sales,

    -- Benchmark 1: Comparison against the product's historical average.
    -- The AVG() window function calculates the average 'current_sales' for each 'product_name'
    -- across all years in the dataset. 'PARTITION BY product_name' is crucial here.
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales_for_product,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS variance_from_avg,
    CASE
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above Average'
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below Average'
        ELSE 'Average'
    END AS performance_vs_avg,

    -- Benchmark 2: Year-over-Year (YoY) Comparison.
    -- The LAG() function accesses data from a previous row in the same result set.
    -- PARTITION BY product_name ensures we only look back at the same product.
    -- ORDER BY order_year tells LAG to fetch the value from the previous year.
    LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
    current_sales - LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY order_year) AS yoy_sales_change,
    -- Calculate YoY growth percentage for a more standardized comparison.
    (current_sales - LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY order_year)) * 100.0
        / NULLIF(LAG(current_sales, 1) OVER (PARTITION BY product_name ORDER BY order_year), 0) AS yoy_growth_percentage
FROM
    yearly_product_sales
ORDER BY
    product_name, order_year;

-- ==============================================================================
-- Section 2: Additional and More Advanced Performance Analysis Queries
-- These queries expand on the theme to answer other critical business questions.
-- ==============================================================================

-- Ques 1: What is the Month-over-Month (MoM) sales growth for each product category?
-- This is crucial for short-term trend analysis and operational adjustments.
WITH monthly_category_sales AS (
    SELECT
        DATETRUNC(month, f.order_date) AS order_month,
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM
        gold.fact_sales f
    LEFT JOIN
        gold.dim_products p ON f.product_key = p.product_key
    WHERE p.category IS NOT NULL
    GROUP BY
        DATETRUNC(month, f.order_date), p.category
)
SELECT
    order_month,
    category,
    total_sales,
    -- Get the sales amount from the previous month for the same category.
    LAG(total_sales, 1) OVER (PARTITION BY category ORDER BY order_month) AS previous_month_sales,
    -- Calculate the MoM growth percentage. NULLIF prevents division by zero.
    (total_sales - LAG(total_sales, 1) OVER (PARTITION BY category ORDER BY order_month)) * 100.0
        / NULLIF(LAG(total_sales, 1) OVER (PARTITION BY category ORDER BY order_month), 0) AS mom_growth_percentage
FROM
    monthly_category_sales
ORDER BY
    category, order_month;


-- Ques 2: How is our active customer base growing Year-over-Year in each country?
-- This shifts the focus from revenue to customer acquisition and retention trends.
WITH yearly_customer_count AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        c.country,
        -- Count distinct customers to find the number of unique active customers.
        COUNT(DISTINCT f.customer_key) AS active_customers
    FROM
        gold.fact_sales f
    LEFT JOIN
        gold.dim_customers c ON f.customer_key = c.customer_key
    WHERE c.country IS NOT NULL
    GROUP BY
        YEAR(f.order_date), c.country
)
SELECT
    order_year,
    country,
    active_customers,
    -- Get the active customer count from the previous year for the same country.
    LAG(active_customers, 1) OVER (PARTITION BY country ORDER BY order_year) AS previous_year_customers,
    -- Calculate the absolute change in the number of active customers.
    active_customers - LAG(active_customers, 1) OVER (PARTITION BY country ORDER BY order_year) AS yoy_customer_growth
FROM
    yearly_customer_count
ORDER BY
    country, order_year;


-- Ques 3: How does the spending of our top 10 customers change Quarter-over-Quarter (QoQ)?
-- This analysis helps in managing key accounts by tracking their purchasing behavior.
WITH CustomerTotalSpending AS (
    -- Step 1: Identify the top 10 customers based on their lifetime spending.
    SELECT
        customer_key,
        SUM(sales_amount) AS total_spending,
        DENSE_RANK() OVER (ORDER BY SUM(sales_amount) DESC) as customer_rank
    FROM gold.fact_sales
    GROUP BY customer_key
),
TopCustomers AS (
    SELECT customer_key FROM CustomerTotalSpending WHERE customer_rank <= 10
),
QuarterlyCustomerSales AS (
    -- Step 2: Aggregate the sales of ONLY the top 10 customers by quarter.
    SELECT
        DATETRUNC(quarter, f.order_date) AS order_quarter,
        f.customer_key,
        c.first_name,
        c.last_name,
        SUM(f.sales_amount) AS quarterly_sales
    FROM
        gold.fact_sales f
    JOIN
        TopCustomers tc ON f.customer_key = tc.customer_key
    JOIN
        gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY
        DATETRUNC(quarter, f.order_date), f.customer_key, c.first_name, c.last_name
)
-- Step 3: Calculate the Quarter-over-Quarter (QoQ) change in spending for these top customers.
SELECT
    order_quarter,
    customer_key,
    first_name,
    last_name,
    quarterly_sales,
    LAG(quarterly_sales, 1) OVER (PARTITION BY customer_key ORDER BY order_quarter) AS previous_quarter_sales,
    (quarterly_sales - LAG(quarterly_sales, 1) OVER (PARTITION BY customer_key ORDER BY order_quarter)) * 100.0
        / NULLIF(LAG(quarterly_sales, 1) OVER (PARTITION BY customer_key ORDER BY order_quarter), 0) AS qoq_spending_change_pct
FROM
    QuarterlyCustomerSales
ORDER BY
    customer_key, order_quarter;
