WITH customer_last_purchase AS (
    SELECT
        customerkey,
        cleaned_name,
        orderdate,
        ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
        first_purchase_date,
        cohort_year
    FROM cohort_analysis
), churned_customers AS(
    SELECT
        customerkey,
        cleaned_name,
        first_purchase_date,
        orderdate AS last_purchase_date,
        CASE
            WHEN orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'   -- '2024-04-20' comes from MAX(orderdate)
            ELSE 'Active'
        END AS  customer_status,
        cohort_year
    FROM customer_last_purchase
    WHERE rn = 1
        -- This mean that we want to start which customer who is 6 month before the max orderdate, since for our case every customer in 2024 will be active, which will be biased. 
        -- Like customer who had made purchase 6 month or more ago, and had made recent purchase
        AND first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' 
)
SELECT
    cohort_year,
    customer_status,
    COUNT(customerkey) AS num_customers,
    SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) AS total_customers,
    ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) , 2)AS status_percentage
FROM 
    churned_customers
GROUP BY 
    cohort_year,
    customer_status

