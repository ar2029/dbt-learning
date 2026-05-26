# Prasoon DBT Learning Project

A hands-on DBT project built while following a DBT tutorial, using **Databricks Free Edition** (Serverless SQL Compute) as the data platform.

## Project Structure

```
prasoon_dbt_cli/
├── models/
│   ├── source/          # Source definitions (sources.yml)
│   └── bronze/          # Raw/ingested layer models
├── macros/              # Custom Jinja macros (e.g. generate_schema_name)
├── profiles-sample.yml  # Safe sample profile (no credentials)
└── dbt_project.yml      # Project-level configuration
```

## Setup

1. Copy `profiles-sample.yml` to `profiles.yml` and fill in your Databricks credentials.
2. `profiles.yml` is gitignored — never commit it.
3. Run `dbt debug` to verify the connection.

## Data Architecture

This project follows a **medallion architecture** using custom schemas to organize data layers:

- **source_schema_dbx** (raw source layer): Contains raw dimension and fact tables ingested from source systems
- **bronze** (bronze layer): DBT transforms raw source tables into bronze models with consistent structure and naming
  - `bronze_dim_customer`, `bronze_dim_date`, `bronze_dim_product`, `bronze_dim_store` (dimension tables)
  - `bronze_fact_returns`, `bronze_fact_sales` (fact tables)

The custom schema configuration in `dbt_project.yml` routes all bronze models to the `bronze` schema:

```yaml
models:
  prasoon_dbt_cli:
    bronze:
      +materialized: table
      schema: bronze
```

### Data Flow Visualization

![Databricks Catalog showing source_schema_dbx and bronze layers](images/databricks_medallion_architecture.png)

The screenshot above shows the Databricks catalog with both the source layer (`source_schema_dbx`) and the bronze layer (`bronze`) created by this DBT project, all running on **Databricks Serverless SQL Compute (2XS warehouse)**.

## Key Commands

```bash
dbt run                          # Run all models
dbt run --select bronze_dim_date # Run a single model
dbt run --select models/bronze/  # Run all bronze models
dbt test                         # Run all tests
dbt clean                        # Remove target/ and dbt_packages/
```

## Learning Notes

See [NOTES.md](NOTES.md) for concept summaries covering DBT models, configurations, custom schemas, and node selection.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a history of what was added or changed.
