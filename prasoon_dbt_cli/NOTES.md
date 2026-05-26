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
# Run all models in the project
dbt run

# Run a specific model by name
dbt run --select <model_name>
```

> `<model_name>` is the name of the SQL file without its extension (e.g. a file called `my_model.sql` is selected as `my_model`).

**Lineage & Troubleshooting:** All models are tracked for lineage. Compiled SQL lives in `target/` and is useful for debugging or verifying transformations.

---

## Custom Config and Properties

Configurations and properties control how models are built and documented. They follow the same hierarchy described above.

**Block-level config** (highest precedence) — defined directly in the SQL file using a Jinja config block:

```sql
{{ config(materialized='<materialization_type>') }}
```

> `<materialization_type>` is one of: `table`, `view`, `incremental`, `ephemeral`.

**Properties file** (`properties.yml`) — sits in the models directory and lets you centralize config for multiple models:

- Model and column descriptions (documentation)
- Generic data tests (`unique`, `not_null`, etc.)
- Model-level configs such as materialization and schema overrides

**Project-level** (`dbt_project.yml`) — best for global defaults, e.g. setting all models in a directory to `table` materialization.

---

## Custom Schemas

By default, DBT builds models in the schema defined in your connection profile. Custom schemas let you route models into specific layers (e.g. bronze, silver, gold) for a clean, layered architecture.

**How it works:**

- Set a `schema:` key in `dbt_project.yml` for a whole directory, or inside a model's `config` block / `properties.yml` entry for per-model control.
- By default, DBT appends the custom schema name to the target schema (e.g. `<target_schema>_<custom_schema>`). To use only the custom schema name as-is, override the `generate_schema_name` macro in your `macros/` folder.

**Example `dbt_project.yml` setup:**

```yaml
models:
  <project_name>:         # matches the `name` field at the top of dbt_project.yml
    <layer_folder_name>:  # matches the folder name under models/
      +materialized: table
      schema: <schema_name>
```

> `+materialized` applies the setting to all models inside that folder. `schema` routes those models to a specific schema in your data warehouse.

**Key takeaway:** Custom schemas are essential for a clean medallion architecture — they enforce logical separation between raw, cleansed, and curated data layers.

---

## DBT Node Selection

Node selection lets you run or test specific parts of your project instead of the entire DAG, saving compute costs during development.

| Use case | Command |
|---|---|
| Run all models | `dbt run` |
| Run a single model | `dbt run --select <model_name>` |
| Run several specific models | `dbt run --select "<model_name_1> <model_name_2>"` |
| Run all models inside a folder | `dbt run --select models/<folder_name>/` |

> `--select` can be shortened to `-s`. Values inside quotes are space-separated model names. A trailing `/` on a path means "all models in this directory".

**Why it matters:** Compute resources on platforms like Databricks are billed by usage. Selecting only the models you are actively working on avoids unnecessary cost.
