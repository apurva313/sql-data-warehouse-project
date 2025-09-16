/*
===============================================================================
-- Sample Queries Section
-- Use these queries to test the views and derive immediate insights.
===============================================================================
*/

-- ==============================================================================
-- Section: Sample Queries Using the Customer Report View
-- ==============================================================================

-- Top 10 customers by total sales
SELECT TOP 10 * FROM gold.report_customers ORDER BY total_sales DESC;

-- Top 10 VIP Customers by Average Order Value
SELECT TOP 10 customer_name, total_sales, avg_order_value
FROM gold.report_customers
WHERE customer_segment = 'VIP'
ORDER BY avg_order_value DESC;

-- Sales performance by Age Group
SELECT age_group, COUNT(customer_key) AS number_of_customers, SUM(total_sales) AS total_revenue, AVG(avg_order_value) AS avg_order_value_for_group
FROM gold.report_customers
GROUP BY age_group
ORDER BY total_revenue DESC;

-- Analyze "New" customer segment
SELECT COUNT(customer_key) AS number_of_new_customers, AVG(total_sales) AS avg_spend_for_new_customers, AVG(total_orders) AS avg_orders_for_new_customers
FROM gold.report_customers
WHERE customer_segment = 'New';

-- Find "Regular" customers at risk of churning (no purchase in >6 months)
SELECT customer_name, last_order_date, recency, total_sales
FROM gold.report_customers
WHERE customer_segment = 'Regular' AND recency > 6
ORDER BY recency DESC;

-- ==============================================================================
-- Section: Sample Queries Using the Product Report View
-- ==============================================================================

-- Top 10 products by total sales
SELECT TOP 10 * FROM gold.report_products ORDER BY total_sales DESC;

-- Performance summary by category
SELECT category, COUNT(product_key) AS number_of_products, SUM(total_sales) AS total_revenue_from_category, AVG(avg_order_revenue) AS avg_order_revenue_in_category,
    AVG(CASE WHEN product_segment = 'High-Performer' THEN 1.0 ELSE 0.0 END) * 100 AS pct_high_performers
FROM gold.report_products
GROUP BY category
ORDER BY total_revenue_from_category DESC;

-- "Low-Performer" products with high cost
SELECT product_name, category, cost, total_sales, total_quantity
FROM gold.report_products
WHERE product_segment = 'Low-Performer' AND cost > 500
ORDER BY cost DESC;

-- Products not sold in over a year (obsolete)
SELECT product_name, subcategory, last_sale_date, recency_in_months, total_sales
FROM gold.report_products
WHERE recency_in_months > 12
ORDER BY recency_in_months DESC;

-- Top 5 products by number of unique customers
SELECT TOP 5 product_name, total_customers, total_sales, product_segment
FROM gold.report_products
ORDER BY total_customers DESC;
