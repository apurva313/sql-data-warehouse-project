/*
===============================================================================
-- Customer Report (Expanded & Corrected Edition)
===============================================================================
Purpose:
    - This script creates a single, comprehensive view named 'gold.report_customers'.
    - The view consolidates key customer metrics, segments, and behaviors into a
      flat, easy-to-query structure, serving as a single source of truth for
      customer analytics.

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into value-based categories (VIP, Regular, New) and
       demographic age groups.
    3. Aggregates customer-level metrics like total orders, sales, quantity,
       unique products purchased, and customer lifespan.
    4. Calculates valuable Key Performance Indicators (KPIs) such as:
       - Recency (months since last order)
       - Average Order Value (AOV)
       - Average Monthly Spend

Design:
    - Uses a series of Common Table Expressions (CTEs) to build the logic in
      sequential, readable steps.
    - Encapsulated within a CREATE VIEW statement, so the report is always
      up-to-date with the underlying data.
===============================================================================
*/

-- =============================================================================
-- Create Report as a View: gold.report_customers
-- =============================================================================

-- Best practice: Check if the view already exists and drop it to ensure a clean re-creation.
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

-- CREATE VIEW statement encapsulates the entire query.
-- The view will act like a virtual table, running this query whenever it's called.
CREATE VIEW gold.report_customers AS

WITH base_query AS (
/*---------------------------------------------------------------------------
Step 1) Base Query: Gathers raw, row-level data.
- This CTE joins the sales and customer tables.
- It calculates basic derived fields like 'customer_name' and 'age'.
- This forms the foundational dataset for subsequent aggregations.
---------------------------------------------------------------------------*/
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    -- Calculate current age based on birthdate.
    DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM
    gold.fact_sales f
LEFT JOIN
    gold.dim_customers c ON c.customer_key = f.customer_key
WHERE
    f.order_date IS NOT NULL AND c.customer_key IS NOT NULL
),

customer_aggregation AS (
/*---------------------------------------------------------------------------
Step 2) Customer Aggregations: Summarizes metrics for each customer.
- This CTE rolls up the row-level data from 'base_query'.
- It calculates key totals and historical metrics like total orders, total sales,
  and the customer's lifespan (time between first and last order).
---------------------------------------------------------------------------*/
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    -- Lifespan in months is a good indicator of customer tenure.
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM
    base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    age
)
/*---------------------------------------------------------------------------
Step 3) Final Report Construction:
- This final SELECT statement pulls from the aggregated data.
- It adds segmentation logic using CASE statements (for age and value).
- It calculates final KPIs like recency, AOV, and average monthly spend.
---------------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Segmentation based on customer age.
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and Above'
    END AS age_group,

    -- Segmentation based on customer value and tenure.
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,
    -- Recency: How many months have passed since the last order?
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan, -- **FIXED**: Added the missing comma before this line.

    -- Compute Average Order Value (AOV). Handle potential division by zero.
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    -- Compute average monthly spend.
    -- If lifespan is 0 (only one month of activity), use total sales.
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM
    customer_aggregation;
GO
