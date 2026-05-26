# Images

## databricks_medallion_architecture.png

Screenshot of the Databricks catalog showing the medallion architecture:
- **source_schema_dbx**: Raw source tables (dim_customer, dim_date, dim_product, dim_store, fact_returns, fact_sales)
- **bronze**: Bronze layer models created by DBT (bronze_dim_customer, bronze_dim_date, bronze_dim_product, bronze_dim_store, bronze_fact_returns, bronze_fact_sales)
- **Compute**: Serverless Starter Warehouse (2XS)
- **Catalog**: dbt_tutorial_catalog_dbx

This image demonstrates the custom schema configuration in action — DBT reads from source_schema_dbx and writes to the bronze schema.
