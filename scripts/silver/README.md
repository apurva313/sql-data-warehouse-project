
# Silver Layer Documentation

Welcome to the Silver Layer of the data warehouse. This layer represents a significant step up from the raw data in the Bronze Layer. Data here has been **cleansed**, **validated**, **conformed**, and **standardized** to create a reliable and queryable source of truth. It serves as the primary source for the final analytics-focused Gold Layer.

-----

## 🏗️ ETL Process: `silver.load_silver`

The entire process of transforming data from Bronze and loading it into this Silver Layer is handled by the `silver.load_silver` stored procedure.

**Key Operations:**

  * **Full Refresh:** Before each run, all Silver tables are `TRUNCATE`d to ensure a complete and fresh data load.
  * **Transformation & Load:** The procedure then extracts data from the Bronze tables, applies a series of cleaning and business rules, and inserts the result into the corresponding Silver tables.

**How to Run the ETL Process:**
To populate or update the Silver Layer, execute the following command:

```sql
EXEC silver.load_silver;
```

-----

## 🗄️ Silver Table Schemas & Transformations

Below is a detailed breakdown of each table in the Silver Layer, including its schema and the specific transformations applied to it from the Bronze Layer.

### ➡️ 1. `silver.crm_cust_info`

This table stores the cleansed and de-duplicated master list of customers.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `cst_id` | `INT` | Unique numeric customer identifier. |
| `cst_key` | `NVARCHAR(50)` | Unique alphanumeric customer key. |
| `cst_firstname` | `NVARCHAR(50)` | Customer's first name. |
| `cst_lastname` | `NVARCHAR(50)` | Customer's last name. |
| `cst_marital_status`| `NVARCHAR(50)` | Customer's marital status. |
| `cst_gndr` | `NVARCHAR(50)` | Customer's gender. |
| `cst_create_date` | `DATE` | The original creation date of the customer record. |
| `dwh_create_date` | `DATETIME2` | Timestamp of when the record was loaded into the DWH. |

**Transformations from Bronze:**

  * **De-duplication:** Only the most recent record for each `cst_id` is kept, based on the `cst_create_date`.
  * **Whitespace Trimming:** Leading/trailing spaces are removed from `cst_firstname` and `cst_lastname`.
  * **Standardization:**
      * `cst_marital_status` codes ('S', 'M') are mapped to user-friendly values ('Single', 'Married'). Others are set to 'n/a'.
      * `cst_gndr` codes ('F', 'M') are mapped to 'Female' and 'Male'.
  * **Filtering:** Records where `cst_id` is `NULL` are excluded.

-----

### ➡️ 2. `silver.crm_prd_info`

Contains cleansed and enriched product information, including derived attributes.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `prd_id` | `INT` | Unique numeric product identifier. |
| `cat_id` | `NVARCHAR(50)` | Derived category ID for easier linking. |
| `prd_key` | `NVARCHAR(50)` | The core unique key for the product. |
| `prd_nm` | `NVARCHAR(50)` | The name of the product. |
| `prd_cost` | `INT` | The cost of the product. |
| `prd_line` | `NVARCHAR(50)` | The descriptive product line. |
| `prd_start_dt` | `DATE` | The date the product version became active. |
| `prd_end_dt` | `DATE` | The date the product version became inactive (SCD Type 2). |
| `dwh_create_date` | `DATETIME2` | Timestamp of when the record was loaded into the DWH. |

**Transformations from Bronze:**

  * **Attribute Derivation:**
      * A new `cat_id` is created by extracting the first 5 characters of the bronze `prd_key`.
      * The `prd_key` is cleaned by removing the category prefix.
  * **Historical Tracking (SCD Type 2):** `prd_end_dt` is calculated as one day before the next version of the product's `prd_start_dt`, creating a historical validity period for each product record.
  * **Data Type Casting:** `prd_start_dt` is cast from `DATETIME` to `DATE`.
  * **Standardization:** Product line codes ('M', 'R', 'S', 'T') are mapped to descriptive names like 'Mountain', 'Road', etc..
  * **Null Handling:** `prd_cost` is set to `0` if it is `NULL`.

-----

### ➡️ 3. `silver.crm_sales_details`

This table holds validated transactional sales data.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `sls_ord_num` | `NVARCHAR(50)` | Unique identifier for the sales order. |
| `sls_prd_key` | `NVARCHAR(50)` | Foreign key for the product sold. |
| `sls_cust_id` | `INT` | Foreign key for the customer. |
| `sls_order_dt` | `DATE` | The date the order was placed. |
| `sls_ship_dt` | `DATE` | The date the order was shipped. |
| `sls_due_dt` | `DATE` | The payment due date. |
| `sls_sales` | `INT` | Total revenue for the line item. |
| `sls_quantity` | `INT` | Number of units sold. |
| `sls_price` | `INT` | Price per unit. |
| `dwh_create_date` | `DATETIME2` | Timestamp of when the record was loaded into the DWH. |

**Transformations from Bronze:**

  * **Date Conversion:** Integer dates (format YYYYMMDD) for `sls_order_dt`, `sls_ship_dt`, and `sls_due_dt` are converted to the standard `DATE` data type. Invalid formats become `NULL`.
  * **Sales Validation:** The `sls_sales` amount is recalculated (`sls_quantity * sls_price`) if the original value is `NULL`, invalid, or inconsistent.
  * **Price Derivation:** `sls_price` is derived (`sls_sales / sls_quantity`) if the original value is `NULL` or invalid, preventing division-by-zero errors.

-----

### ➡️ 4. `silver.erp_loc_a101`

Cleansed customer location data from the ERP system.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `cid` | `NVARCHAR(50)` | Cleansed customer identifier. |
| `cntry` | `NVARCHAR(50)` | Standardized customer country name. |
| `dwh_create_date` | `DATETIME2` | Timestamp of when the record was loaded into the DWH. |

**Transformations from Bronze:**

  * **ID Cleaning:** Hyphens are removed from `cid` values.
  * **Standardization:** Country codes ('DE', 'US', 'USA') are mapped to full country names ('Germany', 'United States'). Blank values are set to 'n/a'.

-----

### ➡️ 5. `silver.erp_cust_az12`

Validated supplementary customer data from the ERP.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `cid` | `NVARCHAR(50)` | Cleansed customer identifier. |
| `bdate` | `DATE` | Customer's date of birth. |
| `gen` | `NVARCHAR(50)` | Standardized customer gender. |
| `dwh_create_date` | `DATETIME2` | Timestamp of when the record was loaded into the DWH. |

**Transformations from Bronze:**

  * **ID Cleaning:** The 'NAS' prefix is stripped from `cid` values where present.
  * **Date Validation:** Any `bdate` set in the future is corrected to `NULL`.
  * **Standardization:** Various gender representations ('F', 'FEMALE', 'M', 'MALE') are consolidated into 'Female' and 'Male'.

-----

### ➡️ 6. `silver.erp_px_cat_g1v2`

Product category information from the ERP.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `id` | `NVARCHAR(50)` | Product identifier. |
| `cat` | `NVARCHAR(50)` | Main product category. |
| `subcat` | `NVARCHAR(50)` | Product sub-category. |
| `maintenance` | `NVARCHAR(50)` | Maintenance information. |
| `dwh_create_date` | `DATETIME2` | Timestamp of when the record was loaded into the DWH. |

**Transformations from Bronze:**

  * **No Transformations:** This table is a direct copy from the Bronze layer, loaded as-is to be used for enrichment in later stages.
