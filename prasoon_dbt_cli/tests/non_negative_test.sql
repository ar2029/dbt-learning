SELECT 
    *
FROM
    {{ ref('bronze_fact_sales') }}
WHERE
    net_amount < 0 OR gross_amount < 0