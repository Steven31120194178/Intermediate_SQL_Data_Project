-- Create a view for a table of cohort analysis
CREATE VIEW cohort_analysis AS
WITH customer_revenue AS (
	SELECT
		s.customerkey,
		s.orderdate,
		SUM(s.quantity * s.netprice * s.exchangerate) AS total_net_revenue,
		COUNT(s.orderkey) AS num_orders,
		c.countryfull,
		c.age,
		c.givenname,
		c.surname
	FROM
		sales s
	LEFT JOIN customer c ON
		c.customerkey = s.customerkey
	GROUP BY
		s.customerkey,
		s.orderdate,
		c.countryfull,
		c.age,
		c.givenname,
		c.surname
)
SELECT
	customerkey,
	orderdate,
	total_net_revenue,
	num_orders,
	countryfull,
	age,
	CONCAT(TRIM(givenname), ' ', TRIM(surname)) AS cleaned_name,  -- Using TRIM just in case if the givennmae or surname have spaces in it
	MIN(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
	EXTRACT(YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM
	customer_revenue cr;

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