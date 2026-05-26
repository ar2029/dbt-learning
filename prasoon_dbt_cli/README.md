# Prasoon DBT Learning Project

A hands-on DBT project built while following a DBT tutorial, using Databricks as the data platform.

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
