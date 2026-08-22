# Changelog

All notable changes to this project are documented here. Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- `NOTES.md` — DBT Tests section covering generic tests (`unique`, `not_null`, `accepted_values`, `relationships`, including multiple tests per column), severity levels (`error`/`warn`), singular tests for business-logic/KPI checks, custom generic tests (`tests/generic/`), and a pointer to unit tests
- `README.md` — Testing section summarizing test types, with a link to `NOTES.md`
- `tests/non_negative_test.sql` — singular test asserting `bronze_fact_sales.net_amount` / `gross_amount` are never negative
- `tests/generic/generic_non_negative.sql` — custom generic test (`generic_non_negative`) reusable across any model/column
- Generic tests wired onto bronze models in `properties.yml`: `unique`/`not_null` on `bronze_dim_product.product_sk`, `bronze_fact_sales.sales_id`, and `bronze_dim_store.store_sk`; `accepted_values` on `bronze_dim_store.store_name`; `generic_non_negative` on `bronze_fact_sales.gross_amount`
- `NOTES.md` — DBT Seeds and The Analysis Folder sections, covering seed config hierarchy, `dbt seed`, referencing seeds via `ref()`, and using `analyses/` for exploratory SQL that never gets built
- `README.md` — Seeds & Analyses section, plus `dbt seed` commands in Key Commands
- `seeds/lookup.csv` — a small customer lookup seed, loaded into the `bronze` schema via `seeds: +schema: bronze` in `dbt_project.yml`
- `analyses/data_exploration.sql` — example analysis referencing the `lookup` seed via `ref()`
- `NOTES.md` — The `target/` Directory section: what it contains, when it's (re)generated vs. cleaned by `dbt clean`, and why it's gitignored rather than committed

---

## [0.2.0] - 2026-05-26

### Added
- `NOTES.md` — learning notes covering DBT models, custom config & properties, custom schemas, and node selection
- `CHANGELOG.md` — this file, to track progress as new concepts are added
- Updated `README.md` with project structure, setup instructions, key commands, and links to notes and changelog

---

## [0.1.0] - 2026-05-25

### Added
- Initial DBT project scaffold (`prasoon_dbt_cli/`)
- Bronze layer models: `bronze_dim_customer`, `bronze_dim_date`, `bronze_dim_product`, `bronze_dim_store`, `bronze_fact_returns`, `bronze_fact_sales`
- Source definitions in `models/source/sources.yml`
- `properties.yml` for bronze layer with model-level configuration
- `dbt_project.yml` with project-level materialization and custom schema config for bronze, silver, and gold layers
- `macros/generate_schema.sql` — overrides default schema name generation to avoid the `default_<schema>` prefix
- `profiles-sample.yml` — credential-free sample profile for safe version control
