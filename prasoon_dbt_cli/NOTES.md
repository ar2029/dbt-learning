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

---

## DBT Tests

Tests validate data integrity and confirm your models meet expectations before downstream layers or BI tools consume them. DBT distinguishes **data tests** (assertions about the data actually in your warehouse) from **unit tests** (assertions about a model's SQL logic using static mock inputs).

**Data tests** are assertions made about project resources — models, sources, seeds, or snapshots. See dbt's [Add data tests to your DAG](https://docs.getdbt.com/docs/build/data-tests) docs for the full reference. They come in two flavors: generic and singular.

**Generic tests** are reusable, pre-defined tests applied to columns via YAML. Four fundamental types:

| Test | Purpose |
|---|---|
| `unique` | Ensures a column contains no duplicate values |
| `not_null` | Confirms a column has no missing (null) values |
| `accepted_values` | Validates that a column's values match a fixed list of allowed entries |
| `relationships` | Verifies that values in one column exist as values in another model's column (referential integrity) |

```yaml
models:
  - name: <model_name>
    columns:
      - name: <column_name>
        data_tests:
          - unique
          - not_null
          - accepted_values:
              values: ['<value_1>', '<value_2>']
          - relationships:
              to: ref('<other_model_name>')
              field: <other_model_column_name>
```

> `data_tests:` sits under a column entry in `properties.yml` (or `schema.yml`). `accepted_values` takes a `values:` list; `relationships` takes `to:` (a `ref()` to the model holding the referenced key) and `field:` (the column name in that model). A column isn't limited to one test — every entry under its `data_tests:` list runs independently, so `unique` and `not_null` (and more) can all sit on the same column at once, as in the example above.

**Severity levels** control whether a failing test blocks the run (`error`, the default) or just warns, without failing `dbt run` or CI:

```yaml
- not_null:
    config:
      severity: warn

- accepted_values:
    arguments:
      values: ['<value_1>', '<value_2>']
    config:
      severity: warn
```

> A test with no arguments (`unique`, `not_null`) just needs `config:`. A test that takes arguments (`accepted_values`, `relationships`) nests `arguments:` and `config:` as siblings under the test name — the values move under `arguments:` instead of sitting directly under the test, once a `config:` block is also present. Use `severity: warn` for a known data-quality issue you want visibility on without blocking the run.

**Singular tests** validate business logic and KPI-style calculations that are too specific for a generic test — e.g. "gross revenue minus returns should never go negative," or a profit margin that shouldn't drop below a threshold. They're plain `.sql` files in `tests/`; dbt runs every file it finds there automatically on `dbt test`. A singular test is just a `select` — any rows it returns are treated as failing records.

```sql
-- tests/<test_name>.sql
select *
from {{ ref('<model_name>') }}
where <column_name> < 0
```

> Singular tests check a layer *after* it's built, so they query it with `ref()` — the same way a downstream model would — rather than `source()`, which points at the raw, pre-dbt data.

**Custom generic tests** let you define your own reusable test, callable just like `unique` or `not_null`. Create a `.sql` file inside `tests/generic/` — `generic` is a fixed folder name dbt looks for — and wrap the logic in a `{% test %}` block, which behaves like a macro:

```sql
-- tests/generic/<test_name>.sql
{% test <test_name>(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} < 0

{% endtest %}
```

> `model` and `column_name` are supplied automatically: `model` resolves to whichever model the test is attached to (equivalent to a `ref()`), and `column_name` to that column's name as a string. Reference it in YAML exactly like a built-in generic test — no `arguments:` needed, since both parameters come from the column it's attached to:

```yaml
data_tests:
  - <test_name>
```

**Execution:**

| Use case | Command |
|---|---|
| Run all tests | `dbt test` |
| Run tests for one model | `dbt test --select <model_name>` |
| Run a single named test | `dbt test --select <test_name>` |

**Unit tests** validate a model's SQL *logic* against static, hand-written mock inputs rather than real warehouse data — no dependency on what's currently in the table. The setup is specific enough to be worth reading directly: see dbt's [Unit tests](https://docs.getdbt.com/docs/build/unit-tests) docs.

**Why it matters:** Tests catch broken assumptions — duplicate keys, orphaned foreign keys, out-of-range values, KPI logic that silently breaks — before they propagate downstream. That matters most in a bronze → silver → gold pipeline, where a bad row compounds at every later layer.
