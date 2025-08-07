-- A CTE for the total_ltv for 25% and 75% (showcase the number we will use)
WITH customer_ltv AS(
  SELECT 
    customerkey,
    cleaned_name,
    SUM(total_net_revenue) AS total_ltv
  FROM cohort_analysis
  GROUP BY
    customerkey,
    cleaned_name
  ORDER BY 
    customerkey
)
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_ltv) AS ltv_25th_percentile,
    PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_ltv) AS ltv_75th_percentile
FROM customer_ltv


-- Total Ltv for each customer with their names(cleaned_name) and a customer segement comparison based on their ltv
WITH customer_ltv AS(
  SELECT 
    customerkey,
    cleaned_name,
    SUM(total_net_revenue) AS total_ltv
  FROM cohort_analysis
  GROUP BY
    customerkey,
    cleaned_name
  ORDER BY 
    customerkey
), customer_segments AS(
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_ltv) AS ltv_25th_percentile,
    PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_ltv) AS ltv_75th_percentile
  FROM customer_ltv
)
SELECT
  c.*,
  CASE
    WHEN c.total_ltv < cs.ltv_25th_percentile THEN '1 - Low-Value'
    WHEN c.total_ltv <= cs.ltv_75th_percentile THEN '2 - Mid-Value'
    ELSE '3 - High-Value'
  END AS customer_segment
FROM 
  customer_ltv c, 
  customer_segments cs