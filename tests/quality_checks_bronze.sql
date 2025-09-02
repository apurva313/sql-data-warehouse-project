/*
===============================================================================
Bronze Layer Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'bronze' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.
Usage Notes:
    - Run these checks after data loading Bronze Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'bronze.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces in First Name
-- Expectation: No Results
SELECT 
    cst_firstname 
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check for Unwanted Spaces in Last Name
-- Expectation: No Results
SELECT 
    cst_lastname 
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standardization & Consistency for Gender
SELECT DISTINCT 
    cst_gndr 
FROM bronze.crm_cust_info;

-- Data Standardization & Consistency for Marital Status
SELECT DISTINCT 
    cst_marital_status 
FROM bronze.crm_cust_info;

-- ====================================================================
-- Checking 'bronze.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) 
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces in Product Name
-- Expectation: No Results
SELECT 
    prd_nm 
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Product Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Data Standardization & Consistency for Product Line
SELECT DISTINCT 
    prd_line 
FROM bronze.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-- Attempt to fix invalid date order example
SELECT 
    *, 
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509', 'AC-HE-HL-U509-R');

-- ====================================================================
-- Checking 'bronze.crm_sales_details'
-- ====================================================================
-- Check for Invalid Order Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
   OR LEN(sls_order_dt) != 8 
   OR sls_order_dt > 20500101 
   OR sls_order_dt < 19000101;

-- Check for Invalid Ship Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
   OR LEN(sls_ship_dt) != 8 
   OR sls_ship_dt > 20500101 
   OR sls_ship_dt < 19000101;

-- Check for Invalid Due Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
   OR LEN(sls_due_dt) != 8 
   OR sls_due_dt > 20500101 
   OR sls_due_dt < 19000101;

-- Check for Invalid Date Ranges (Order Date > Ship or Due Date)
-- Expectation: No Results
SELECT 
    * 
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Also handle NULLs and zero or negative values by recalculating
SELECT DISTINCT
    sls_sales AS old_sales,
    sls_quantity,
    sls_price AS old_price,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS new_sales,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS new_sales_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;

-- ====================================================================
-- Checking 'bronze.erp_cust_az12'
-- ====================================================================
-- Check for Duplicate Customer IDs
-- Expectation: No Results
SELECT 
    cid,
    COUNT(*) 
FROM bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;

-- Check for Birthdate Out-of-Range (should be between 1924-01-01 and today)
SELECT 
    bdate 
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Data Standardization & Consistency for Gender
SELECT 
    DISTINCT gen,
    COUNT(*)
FROM bronze.erp_cust_az12
GROUP BY gen;

-- Gender Value Standardization Query Example
SELECT	
    DISTINCT gen,
    CASE 
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS standardized_gen
FROM bronze.erp_cust_az12;

-- ====================================================================
-- Checking 'bronze.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency for Country Codes & Names
SELECT
    DISTINCT cntry,
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS standardized_cntry
FROM bronze.erp_loc_a101;
