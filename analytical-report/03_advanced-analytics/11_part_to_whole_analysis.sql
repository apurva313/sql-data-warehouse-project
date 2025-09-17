/*
===============================================================================
-- Part-to-Whole Analysis (Expanded Edition)
===============================================================================
Purpose:
    - To understand the contribution of individual segments (the "parts") to the
      overall total (the "whole").
    - This analysis is essential for identifying the most significant contributors
      to a metric, such as which product category generates the most revenue or
      which country has the most customers.
    - It is commonly used for resource allocation, focus strategies (e.g., Pareto
      Principle), and high-level business reporting.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT()
    - Window Functions: SUM() OVER() is the key function, used to calculate the grand
      total across all rows for percentage calculations.
    - Common Table Expressions (CTEs): To structure the query logically.
===============================================================================
*/

-- ==============================================================================
-- Section 1: Sales Contribution by Product Category (Enhanced from Original)
-- This query calculates what percentage of total sales each product category is
-- responsible for.
-- ==============================================================================

-- A CTE is used to first calculate the total sales for each category.
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM
        gold.fact_sales f
    LEFT JOIN
        gold.dim_products p ON p.product_key = f.product_key
    WHERE
        p.category IS NOT NULL
    GROUP BY
        p.category
)
-- The main query then calculates the percentage contribution.
SELECT
    category,
    total_sales,

    -- The SUM(total_sales) OVER () window function calculates the grand total of sales
    -- across all categories. The empty OVER() clause tells it to operate on the entire result set.
    -- This avoids a second, more complex query just to get the total.
    SUM(total_sales) OVER () AS overall_sales,

    -- To calculate the percentage, we divide the sales of one category by the overall total.
    -- We must CAST total_sales to a float or decimal type to ensure accurate division,
    -- otherwise, SQL might perform integer division.
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM
    category_sales
ORDER BY
    total_sales DESC;

-- ==============================================================================
-- Section 2: Additional and More Advanced Part-to-Whole Queries
-- ==============================================================================

-- Ques 1: What is the sales contribution percentage of each country?
-- This helps identify key geographical markets.
WITH country_sales AS (
    SELECT
        c.country,
        SUM(f.sales_amount) AS total_sales
    FROM
        gold.fact_sales f
    LEFT JOIN
        gold.dim_customers c ON f.customer_key = c.customer_key
    WHERE
        c.country IS NOT NULL
    GROUP BY
        c.country
)
SELECT
    country,
    total_sales,
    -- Calculate the percentage contribution of each country towards the grand total of sales.
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total_sales
FROM
    country_sales
ORDER BY
    percentage_of_total_sales DESC;


-- Ques 2: What is the sales mix within each category? (Subcategory Contribution)
-- This is a multi-level part-to-whole analysis. We want to see two things:
-- 1. A subcategory's sales as a percentage of its parent category.
-- 2. A subcategory's sales as a percentage of the overall total sales.
WITH subcategory_sales AS (
    SELECT
        p.category,
        p.subcategory,
        SUM(f.sales_amount) AS total_sales
    FROM
        gold.fact_sales f
    LEFT JOIN
        gold.dim_products p ON p.product_key = f.product_key
    WHERE
        p.category IS NOT NULL AND p.subcategory IS NOT NULL
    GROUP BY
        p.category, p.subcategory
)
SELECT
    category,
    subcategory,
    total_sales,

    -- Use PARTITION BY category to get the total sales for just the parent category.
    SUM(total_sales) OVER (PARTITION BY category) AS total_category_sales,

    -- % of Parent Category: (Subcategory Sales / Parent Category Sales)
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER (PARTITION BY category)) * 100, 2) AS pct_of_category,

    -- % of Grand Total: (Subcategory Sales / Overall Total Sales)
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS pct_of_grand_total
FROM
    subcategory_sales
ORDER BY
    category, total_sales DESC;


-- Ques 3: Do our customers follow the Pareto Principle (80/20 Rule)?
-- Let's find out what percentage of customers contribute to 80% of total sales.
WITH CustomerSpending AS (
    -- Step 1: Calculate total spending per customer.
    SELECT
        customer_key,
        SUM(sales_amount) AS total_spending
    FROM
        gold.fact_sales
    GROUP BY
        customer_key
),
RankedCustomers AS (
    -- Step 2: Calculate the cumulative percentage of customers and revenue.
    SELECT
        customer_key,
        total_spending,
        -- Calculate the cumulative percentage of revenue
        SUM(total_spending) OVER (ORDER BY total_spending DESC) * 100.0
            / (SELECT SUM(total_spending) FROM CustomerSpending) AS cumulative_revenue_pct,
        -- Calculate the cumulative percentage of customers
        ROW_NUMBER() OVER (ORDER BY total_spending DESC) * 100.0
            / (SELECT COUNT(*) FROM CustomerSpending) AS cumulative_customer_pct
    FROM
        CustomerSpending
)
-- Step 3: Find the point where the cumulative revenue crosses 80%.
SELECT
    -- This gives us the percentage of top customers who are responsible for ~80% of revenue.
    MIN(cumulative_customer_pct) AS top_customer_pct_for_80_pct_revenue
FROM
    RankedCustomers
WHERE
    cumulative_revenue_pct >= 80;
