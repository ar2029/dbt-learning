-- you can use the ref function to reference a model or seed. For example, if you have a seed called 'lookup', you can reference it in your analysis like this:
SELECT 
    *
FROM
    {{ ref('lookup') }}