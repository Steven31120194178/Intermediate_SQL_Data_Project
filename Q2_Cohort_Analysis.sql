-- On Top of that, now we're trying to find Cohort quality — how valuable each year’s 'new customers' are at the moment they joined
-- That being said, we need to set their orderdate = first_purchase_date (excluded future purchases)


SELECT
  cohort_year,
  COUNT(DISTINCT customerkey) AS total_customers,  -- using distinct since customer might makes more purchases in a year
  SUM(total_net_revenue) AS total_revenue,
  SUM(total_net_revenue) / COUNT(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis
WHERE orderdate = first_purchase_date  -- This query analyzes first-purchase behavior per cohort year.
GROUP BY
  cohort_year

-- Key Part: If a customer makes two orders on the same date which is also their first order, both of them will be included in net revenue.