
# Bronze Layer Schema Documentation

This document provides a detailed overview of the tables within the `bronze` schema. This layer holds raw, unprocessed data ingested directly from source systems (CRM and ERP). The structure mirrors the source as closely as possible, with minimal transformations.

-----

## 🗄️ Bronze Layer Tables

The following tables are defined in the `bronze` schema.

### Source: CRM

#### ➡️ 1. `crm_cust_info` (Customer Master)

Stores fundamental information about each customer.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `cst_id` | `INT` | A unique numeric identifier for the customer. |
| `cst_key` | `NVARCHAR(50)`| A unique alphanumeric key for the customer. |
| `cst_firstname` | `NVARCHAR(50)`| The customer's first name. |
| `cst_lastname` | `NVARCHAR(50)`| The customer's last name. |
| `cst_marital_status`| `NVARCHAR(50)`| The customer's marital status (e.g., 'Married', 'Single'). |
| `cst_gndr` | `NVARCHAR(50)`| The gender of the customer. |
| `cst_create_date` | `DATE` | The date the customer record was first created. |

#### ➡️ 2. `crm_prd_info` (Product Master)

Contains details for each product offered.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `prd_id` | `INT` | A unique numeric identifier for the product. |
| `prd_key` | `NVARCHAR(50)`| A unique alphanumeric key for the product. |
| `prd_nm` | `NVARCHAR(50)`| The name of the product. |
| `prd_cost` | `INT` | The manufacturing or acquisition cost of the product. |
| `prd_line` | `NVARCHAR(50)`| The product line or family it belongs to. |
| `prd_start_dt` | `DATETIME` | The timestamp when the product was introduced. |
| `prd_end_dt` | `DATETIME` | The timestamp when the product was discontinued (if applicable). |

#### ➡️ 3. `crm_sales_details` (Sales Transactions)

Holds records for each individual sales order line item.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `sls_ord_num` | `NVARCHAR(50)`| The unique identifier for a sales order. |
| `sls_prd_key` | `NVARCHAR(50)`| The key of the product sold. **Likely foreign key to `crm_prd_info.prd_key`**. |
| `sls_cust_id` | `INT` | The ID of the customer who made the purchase. **Likely foreign key to `crm_cust_info.cst_id`**. |
| `sls_order_dt` | `INT` | The date of the order, stored as an integer (e.g., YYYYMMDD). |
| `sls_ship_dt` | `INT` | The date the order was shipped, stored as an integer. |
| `sls_due_dt` | `INT` | The payment due date for the order, stored as an integer. |
| `sls_sales` | `INT` | The total revenue from the sale of this line item. |
| `sls_quantity` | `INT` | The number of units of the product sold. |
| `sls_price` | `INT` | The price per unit for this transaction. |

### Source: ERP

#### ➡️ 4. `erp_loc_a101` (Customer Location)

Contains geographic information for customers. The cryptic name is inherited from the source system.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `cid` | `NVARCHAR(50)`| Customer identifier. **Likely foreign key to `crm_cust_info.cst_key`**. |
| `cntry` | `NVARCHAR(50)`| The country where the customer resides. |

#### ➡️ 5. `erp_cust_az12` (Supplementary Customer Data)

Stores additional demographic details for customers.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `cid` | `NVARCHAR(50)`| Customer identifier. **Likely foreign key to `crm_cust_info.cst_key`**. |
| `bdate` | `DATE` | The customer's date of birth. |
| `gen` | `NVARCHAR(50)`| The gender of the customer (may be redundant with `crm_cust_info.cst_gndr`). |

#### ➡️ 6. `erp_px_cat_g1v2` (Product Categories)

Provides a hierarchical categorization for products.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `id` | `NVARCHAR(50)`| Product identifier. **Likely foreign key to `crm_prd_info.prd_key`**. |
| `cat` | `NVARCHAR(50)`| The main product category. |
| `subcat` | `NVARCHAR(50)`| The product sub-category. |
| `maintenance`| `NVARCHAR(50)`| Maintenance-related information or flag. |

-----

## 🔗 Inferred Relationships

  * **Customers and Sales:** `crm_cust_info` joins with `crm_sales_details` on `cst_id` = `sls_cust_id`.
  * **Products and Sales:** `crm_prd_info` joins with `crm_sales_details` on `prd_key` = `sls_prd_key`.
  * **Customer Enrichment:** `crm_cust_info` can be enriched with `erp_loc_a101` and `erp_cust_az12` using `cst_key` = `cid`.
  * **Product Enrichment:** `crm_prd_info` can be enriched with `erp_px_cat_g1v2` using `prd_key` = `id`.

-----

## 📝 General Notes & Observations

  * **Data Consistency:** The bronze layer preserves inconsistencies from the source, such as different naming conventions for customer IDs (`cst_id`, `cst_key`, `cid`). These will be standardized in the Silver layer.
  * **Date Formatting:** Dates in the `crm_sales_details` table are stored as `INT`. They will require casting and transformation into a standard `DATE` format for analysis.
  * **Data Integrity:** This DDL script does not define primary keys, foreign keys, or other constraints. This is a common practice in the bronze layer to ensure that ingestion processes do not fail due to data quality issues at the source. Data validation and integrity checks are typically enforced in the Silver layer.
  * **Redundancy:** The gender column appears in both `crm_cust_info` (`cst_gndr`) and `erp_cust_az12` (`gen`). A data cleaning strategy will be needed to consolidate this information.
