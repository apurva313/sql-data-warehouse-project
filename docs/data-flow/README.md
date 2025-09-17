# Data Flow & Lineage

This section illustrates the end-to-end data lineage, tracing the path of data from its raw source files to the final, business-ready views in the Gold layer.

![data_flow](https://github.com/user-attachments/assets/1cec5981-6fcc-47bc-87fe-7b0da6c5fbfb)

-----

### 1\. Source to Bronze Ingestion

Raw data from CRM and ERP source files is loaded directly into corresponding tables in the Bronze layer. This initial step is a one-to-one mapping that preserves the original structure of the source data.

  * **CRM Source** loads into:
      * `crm_sales_details`
      * `crm_cust_info`
      * `crm_prd_info`
  * **ERP Source** loads into:
      * `erp_cust_az12`
      * `erp_loc_a101`
      * `erp_px_cat_g1v2`

-----

### 2\. Bronze to Silver Cleansing

Each table in the Bronze layer is processed and loaded into a corresponding table in the Silver layer. This stage maintains a one-to-one flow between the Bronze and Silver tables.

-----

### 3\. Silver to Gold Transformation

The Gold layer integrates data from multiple Silver tables and remodels it into a Star Schema with dimension and fact views.

  * **`dim_customers`**: This dimension view is created by combining data from three Silver tables: `crm_cust_info`, `erp_cust_az12`, and `erp_loc_a101`.
  * **`dim_products`**: This dimension view is created by joining `crm_prd_info` with `erp_px_cat_g1v2`.
  * **`fact_sales`**: This fact view is built from the `crm_sales_details` table.
