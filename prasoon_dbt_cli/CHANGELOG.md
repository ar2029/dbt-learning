# Changelog

All notable changes to this project are documented here. Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

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
