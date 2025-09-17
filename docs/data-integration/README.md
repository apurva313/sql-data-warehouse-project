# Data Integration & Relationships

This section details how tables from the Customer Relationship Management (CRM) and Enterprise Resource Planning (ERP) systems are related. The diagram illustrates the key relationships that allow for the creation of a unified view of customers, products, and sales.

![data_integration](https://github.com/user-attachments/assets/07abe27f-2d6b-4f89-b3b3-72535d5afd64)

-----

### Customer Data Integration

A complete customer profile is built by linking the core CRM customer table with supplementary data from the ERP system.

  * The `crm_cust_info` table from CRM serves as the primary source for customer information.
  * It is linked to `erp_cust_az12` for extra information like birthdate and `erp_loc_a101` for location data.
  * The relationship is established using the `crm_cust_info.cst_key` and the `cid` columns in the ERP tables.

### Product Data Integration

Product information is enriched by combining product master data from the CRM with product category data from the ERP.

  * The `crm_prd_info` table contains current and historical product information.
  * It connects to the `erp_px_cat_g1v2` table to get product category details.
  * This link is made between the `crm_prd_info.prd_key` and the `erp_px_cat_g1v2.id` columns.

### Transactional Data Integration

The `crm_sales_details` table holds the transactional records and acts as the central point that connects customers to the products they purchase.

  * It links to the `crm_cust_info` table on the `cst_id` column to identify the customer.
  * It links to the `crm_prd_info` table on the `prd_key` column to identify the product sold.
