# DBT Learning Notes

Concept summaries from following a DBT tutorial. Updated as new topics are covered.

---

## DBT Models

Models are the core component where transformation logic is defined — they hold the SQL that defines how data is transformed (the "T" in ELT).

**Materialization** controls how a model is built in the database (as a table or a view). This can be set in `dbt_project.yml` or overridden at the model level.

**Hierarchy of Configuration** (highest to lowest precedence):

1. **Block level** — `{{ config(...) }}` inside the SQL file itself
2. **Properties** — `properties.yml` (or `schema.yml`) in the models directory
3. **Project level** — `dbt_project.yml`

**Execution:**

```bash
dbt run                          # Run all models
dbt run --select <model_name>    # Run one model
```

**Lineage & Troubleshooting:** All models are tracked for lineage. Compiled SQL lives in `target/` and is useful for debugging or verifying transformations.

---

## Custom Config and Properties

Configurations and properties control how models are built and documented. They follow the same hierarchy described above.

**Block-level config** (highest precedence) — defined directly in the SQL file:

```sql
{{ config(materialized='view') }}
```

**Properties file** (`properties.yml`) — sits in the models directory and lets you centralize config for multiple models:

- Model and column descriptions (documentation)
- Generic data tests (`unique`, `not_null`, etc.)
- Model-level configs such as materialization and schema overrides

**Project-level** (`dbt_project.yml`) — best for global defaults, e.g. setting all bronze models to `table` materialization.

---

## Custom Schemas

By default, DBT builds models in the schema defined in your connection profile. Custom schemas let you route models into specific layers (bronze, silver, gold) for a clean, layered architecture.

**How it works:**

- Set a `schema:` key in `dbt_project.yml` for a whole directory, or in a model's `config` block / `properties.yml` entry for granular control.
- By default, DBT appends the custom schema name to the target schema (e.g. `default_bronze`). To use the schema name as-is (just `bronze`), override the `generate_schema_name` macro in your `macros/` folder.

**Example `dbt_project.yml` setup:**

```yaml
models:
  my_project:
    bronze:
      +materialized: table
      schema: bronze
    silver:
      +materialized: table
      schema: silver
```

**Key takeaway:** Custom schemas are essential for a clean medallion architecture — they enforce logical separation between raw, cleansed, and curated data layers.

---

## DBT Node Selection

Node selection lets you run or test specific parts of your project instead of the entire DAG, saving compute costs during development.

| Command | What it does |
|---|---|
| `dbt run --select bronze_dim_date` | Run a single named model |
| `dbt run --select "bronze_dim_date bronze_dim_store"` | Run multiple specific models |
| `dbt run --select models/bronze/` | Run all models in a directory |

Use `-s` as a shorthand for `--select`.

**Why it matters:** Compute resources on platforms like Databricks are expensive. Targeting only the models you are actively developing avoids unnecessary cost.
