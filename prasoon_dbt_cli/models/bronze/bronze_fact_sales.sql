{{ config(materialized='view') }}

select * from {{ source("source_schema", "fact_sales") }}
