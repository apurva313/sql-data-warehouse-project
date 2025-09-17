
# Gold Layer Documentation

Welcome to the Gold Layer, the final and most refined stage of our data warehouse. This layer is designed specifically for analytics, business intelligence (BI), and reporting. The data is modeled into a user-friendly **Star Schema**, consisting of central fact tables and surrounding dimension tables.

The views in this layer provide a clean, enriched, and aggregated perspective of the business, making it easy for analysts and BI tools (like Power BI or Tableau) to consume and derive insights.

-----

## 🏛️ Schema Model: Star Schema

The Gold Layer is structured as a classic Star Schema, which is optimized for fast querying and easy comprehension.

  * **Fact Table:** A central table containing quantitative business measurements (the "facts").
  * **Dimension Tables:** Descriptive tables that provide context to the facts.

This model is composed of one fact view and two dimension views:

```
             +--------------------+
             |  gold.dim_customers  |  (Context: Who bought it?)
             +--------------------+
                   |
        +----------+-------------+
        |    gold.fact_sales    |    (Measurements: How much? How many?)
        +----------+-------------+
                   |
             +--------------------+
             |   gold.dim_products  |   (Context: What was bought?)
             +--------------------+
```

-----

## VIEW Definitions

The following views are created by joining and transforming data from the Silver Layer.

### ➡️ 1. `gold.dim_customers` (Dimension)

This view creates a single, consolidated record for each customer, combining information from multiple source systems. It answers the "who" and "where" questions about the data.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `customer_key` | `BIGINT` | **Surrogate Key**. A unique, stable identifier for the customer dimension. |
| `customer_id` | `INT` | The original customer ID from the source system. |
| `customer_number` | `NVARCHAR(50)`| The original customer key from the source system. |
| `first_name` | `NVARCHAR(50)`| Customer's first name. |
| `last_name` | `NVARCHAR(50)`| Customer's last name. |
| `country` | `NVARCHAR(50)`| The country where the customer resides. |
| `marital_status` | `NVARCHAR(50)`| Customer's marital status. |
| `gender` | `NVARCHAR(50)`| The customer's gender, consolidated from CRM and ERP data. |
| `birthdate` | `DATE` | The customer's date of birth. |
| `create_date` | `DATE` | The date the customer record was first created. |

<img width="666" height="400" alt="dim_customers" src="https://github.com/user-attachments/assets/911cb3b6-2460-4746-834f-1d842def0ae2" />

**Key Business Logic & Transformations:**

  * **Surrogate Key Generation:** A new `customer_key` is generated to provide a stable key for analytics, independent of the source system IDs.
  * **Data Consolidation:** It joins `silver.crm_cust_info`, `silver.erp_cust_az12`, and `silver.erp_loc_a101` to create a complete 360-degree view of the customer.
  * **Gender Coalescing:** A single, reliable `gender` field is created. It prioritizes the primary CRM source data and uses the ERP data as a fallback if the CRM data is not available ('n/a').
  * **Business-Friendly Naming:** Columns are renamed to be intuitive for analysts (e.g., `cst_firstname` becomes `first_name`).

-----

### ➡️ 2. `gold.dim_products` (Dimension)

This view represents the master list of **current and active products**. It provides the descriptive attributes of the products sold and answers the "what" questions.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `product_key` | `BIGINT` | **Surrogate Key**. A unique identifier for the product dimension. |
| `product_id` | `INT` | The original product ID from the source system. |
| `product_number` | `NVARCHAR(50)`| The original clean product key. |
| `product_name` | `NVARCHAR(50)`| The name of the product. |
| `category_id` | `NVARCHAR(50)`| The ID of the product category. |
| `category` | `NVARCHAR(50)`| The main category of the product. |
| `subcategory` | `NVARCHAR(50)`| The subcategory of the product. |
| `maintenance` | `NVARCHAR(50)`| Maintenance-related information. |
| `cost` | `INT` | The cost of the product. |
| `product_line` | `NVARCHAR(50)`| The product line (e.g., 'Mountain', 'Road'). |
| `start_date` | `DATE` | The date the product became available for sale. |

<img width="666" height="400" alt="dim_products" src="https://github.com/user-attachments/assets/d822d497-5979-4e00-a0df-a35bfc42eab5" />

**Key Business Logic & Transformations:**

  * **Active Products Only:** This is a critical business rule. The view is filtered with `WHERE pn.prd_end_dt IS NULL` to ensure that it only contains the most recent, active version of each product, excluding all historical records.
  * **Data Enrichment:** The view joins `silver.crm_prd_info` with `silver.erp_px_cat_g1v2` to enrich the core product data with its corresponding category and subcategory information.
  * **Surrogate Key Generation:** A `product_key` is generated to serve as a stable join key for the fact table.
  * **Intuitive Aliases:** Columns are renamed for ease of use in BI tools (e.g., `prd_nm` becomes `product_name`).

-----

### ➡️ 3. `gold.fact_sales` (Fact Table)

This is the central fact view, containing the quantitative measures of the sales process. It connects the dimensions and holds the metrics that will be analyzed, such as sales amount and quantity.

**Schema:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `order_number` | `NVARCHAR(50)`| The unique identifier for the sales order. |
| `product_key` | `BIGINT` | **Foreign Key** to `gold.dim_products`. |
| `customer_key` | `BIGINT` | **Foreign Key** to `gold.dim_customers`. |
| `order_date` | `DATE` | The date the order was placed. |
| `shipping_date` | `DATE` | The date the order was shipped. |
| `due_date` | `DATE` | The payment due date. |
| `sales_amount` | `INT` | **Measure**. The total revenue from the sale. |
| `quantity` | `INT` | **Measure**. The number of units sold. |
| `price` | `INT` | **Measure**. The price per unit for the transaction. |

<img width="666" height="400" alt="fact_sales" src="https://github.com/user-attachments/assets/dd30f15f-d7e0-4bbb-87b1-731b6882a183" />


**Key Business Logic & Transformations:**

  * **Dimensional Linkage:** This view connects the transactional data from `silver.crm_sales_details` to the dimension views (`dim_customers` and `dim_products`) using the stable surrogate keys (`customer_key`, `product_key`).
  * **Schema Simplification:** By joining with the dimensions, it replaces source-specific IDs (`sls_prd_key`, `sls_cust_id`) with the unified surrogate keys, simplifying the model for end-users.
  * **Clarity:** Columns are renamed to clear, business-friendly names (e.g., `sls_sales` becomes `sales_amount`).
