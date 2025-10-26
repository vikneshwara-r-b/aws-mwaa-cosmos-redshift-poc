{{
    config(
        materialized='view'
    )
}}

SELECT 
    *
FROM {{ ref('sales') }}
