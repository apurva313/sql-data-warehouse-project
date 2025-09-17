/*
===============================================================================
-- Data Segmentation Analysis (Expanded Edition)
===============================================================================
Purpose:
    - To divide data into distinct, meaningful groups (segments) based on shared
      characteristics for more targeted analysis.
    - Common applications include customer segmentation (e.g., by value, behavior,
      or demographics), product categorization, and regional analysis.
    - Segmentation allows businesses to tailor marketing, sales, and product strategies
      to different groups.

SQL Functions Used:
    - CASE Statements: The core tool for defining custom segmentation logic.
    - Common Table Expressions (CTEs): To build intermediate, logical steps before
      the final aggregation.
    - Aggregate Functions: COUNT(), SUM(), MIN(), MAX() to summarize data for segmentation.
    - Window Functions: SUM() OVER(), NTILE() for more advanced segmentation like RFM or ABC.
===============================================================================
*/

-- ==============================================================================
-- Section 1: Product and Customer Segmentation (Enhanced from Original)
-- ==============================================================================

-- Query 1.1: Segment products into cost ranges.
-- This helps in understanding the distribution of products across different price points.
WITH product_segments AS (
    -- Step 1: Use a CTE to assign a cost segment to each product.
    SELECT
        product_key,
        product_name,
        cost,
        -- The CASE statement acts like an if-then-else block to create custom labels.
        -- It evaluates each condition sequentially and assigns the product to a 'cost_range'.
        CASE 
            WHEN cost < 100 THEN 'Low-Cost (< 100)'
            WHEN cost BETWEEN 100 AND 500 THEN 'Mid-Range (100-500)'
            WHEN cost BETWEEN 500 AND 1000 THEN 'High-Cost (500-1000)'
            ELSE 'Premium (> 1000)'
        END AS cost_range
    FROM 
        gold.dim_products
)
-- Step 2: Count the number of products that fall into each defined segment.
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM 
    product_segments
GROUP BY 
    cost_range
ORDER BY 
    -- Ordering by a specific part of the string to ensure logical sort order.
    MIN(cost);


-- Query 1.2: Segment customers based on their purchasing history and value.
-- This creates a simple value-based segmentation model (New, Regular, VIP).
WITH customer_spending AS (
    -- Step 1: Aggregate sales data for each customer to get key metrics.
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        -- Calculate the customer's lifespan in months from their first to last order.
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
    FROM 
        gold.fact_sales f
    LEFT JOIN 
        gold.dim_customers c ON f.customer_key = c.customer_key
    WHERE 
        c.customer_key IS NOT NULL
    GROUP BY 
        c.customer_key
)
-- Step 2: Apply the segmentation logic using a subquery on the aggregated data.
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers,
    AVG(total_spending) AS avg_spending_in_segment
FROM (
    SELECT 
        customer_key,
        total_spending,
        -- Use a CASE statement to assign each customer to a segment based on rules.
        CASE 
            WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP Customer'
            WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular Customer'
            ELSE 'New Customer' -- Customers with less than 12 months of history.
        END AS customer_segment
    FROM 
        customer_spending
) AS segmented_customers
GROUP BY 
    customer_segment
ORDER BY 
    total_customers DESC;

-- ==============================================================================
-- Section 2: Additional and More Advanced Segmentation Queries
-- ==============================================================================

-- Ques 1: Segment customers by age group and analyze their total spending.
-- This demographic segmentation helps in understanding the purchasing power of different generations.
WITH CustomerAgeGroups AS (
    SELECT
        c.customer_key,
        -- Calculate the age of the customer as of today's date.
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age,
        f.sales_amount
    FROM
        gold.dim_customers c
    JOIN
        gold.fact_sales f ON c.customer_key = f.customer_key
    WHERE
        c.birthdate IS NOT NULL
)
SELECT
    -- Use a CASE statement to assign each customer to a generational cohort.
    CASE
        WHEN age <= 28 THEN 'Gen Z (<=28)'
        WHEN age BETWEEN 29 AND 44 THEN 'Millennials (29-44)'
        WHEN age BETWEEN 45 AND 60 THEN 'Gen X (45-60)'
        ELSE 'Boomers & Older (>60)'
    END AS age_segment,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales
FROM
    CustomerAgeGroups
GROUP BY
    CASE
        WHEN age <= 28 THEN 'Gen Z (<=28)'
        WHEN age BETWEEN 29 AND 44 THEN 'Millennials (29-44)'
        WHEN age BETWEEN 45 AND 60 THEN 'Gen X (45-60)'
        ELSE 'Boomers & Older (>60)'
    END
ORDER BY
    total_sales DESC;


-- Ques 2: Segment products using ABC Analysis based on their contribution to total revenue.
-- A-grade: Top 70% of revenue. B-grade: Next 20%. C-grade: Bottom 10%.
-- This is a powerful inventory management technique.
WITH ProductRevenue AS (
    -- Step 1: Calculate total revenue for each product.
    SELECT
        p.product_name,
        SUM(f.sales_amount) as total_revenue
    FROM
        gold.fact_sales f
    JOIN
        gold.dim_products p ON f.product_key = p.product_key
    GROUP BY
        p.product_name
),
CumulativeRevenue AS (
    -- Step 2: Calculate the cumulative revenue percentage.
    SELECT
        product_name,
        total_revenue,
        -- The window function calculates the running total of revenue, then divides by the grand total.
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) * 100.0 /
            (SELECT SUM(total_revenue) FROM ProductRevenue) AS cumulative_percentage
    FROM
        ProductRevenue
)
-- Step 3: Assign ABC segments based on the cumulative percentage.
SELECT
    CASE
        WHEN cumulative_percentage <= 70 THEN 'A-Grade Products'
        WHEN cumulative_percentage <= 90 THEN 'B-Grade Products' -- (70% + 20% = 90%)
        ELSE 'C-Grade Products'
    END AS abc_segment,
    COUNT(*) AS number_of_products,
    SUM(total_revenue) as revenue_in_segment
FROM
    CumulativeRevenue
GROUP BY
    CASE
        WHEN cumulative_percentage <= 70 THEN 'A-Grade Products'
        WHEN cumulative_percentage <= 90 THEN 'B-Grade Products'
        ELSE 'C-Grade Products'
    END
ORDER BY revenue_in_segment DESC;


-- Ques 3: Segment customers by purchase recency (RFM's 'R').
-- This helps identify active, at-risk, and churned customers.
WITH CustomerLastPurchase AS (
    -- Step 1: Find the last purchase date for each customer.
    SELECT
        customer_key,
        MAX(order_date) AS last_purchase_date
    FROM
        gold.fact_sales
    GROUP BY
        customer_key
)
-- Step 2: Calculate the difference in months from today and assign a segment.
SELECT
    CASE
        WHEN DATEDIFF(month, last_purchase_date, GETDATE()) <= 6 THEN 'Active (Last 6 Months)'
        WHEN DATEDIFF(month, last_purchase_date, GETDATE()) <= 12 THEN 'At Risk (6-12 Months)'
        ELSE 'Churned (>12 Months)'
    END AS recency_segment,
    COUNT(customer_key) AS number_of_customers
FROM
    CustomerLastPurchase
GROUP BY
    CASE
        WHEN DATEDIFF(month, last_purchase_date, GETDATE()) <= 6 THEN 'Active (Last 6 Months)'
        WHEN DATEDIFF(month, last_purchase_date, GETDATE()) <= 12 THEN 'At Risk (6-12 Months)'
        ELSE 'Churned (>12 Months)'
    END
ORDER BY
    MIN(last_purchase_date) DESC;
