WITH store_revenue AS (
   SELECT
      s.storekey,
      st.squaremeters,
      SUM(s.quantity * s.netprice * s.exchangerate) AS revenue
   FROM sales s
   INNER JOIN store st ON s.storekey = st.storekey
   WHERE s.orderdate BETWEEN '2023-01-01' AND '2023-12-31'
   GROUP BY s.storekey, st.squaremeters
)
SELECT
  CASE
      WHEN squaremeters < 1000 AND revenue < 100000
        THEN '1 - Small Store - Low Revenue'
      WHEN squaremeters < 1000 AND revenue >= 100000
        THEN '2 - Small Store - High Revenue'

      WHEN squaremeters BETWEEN 1000 AND 2000 AND revenue < 300000
        THEN '3 - Medium Store - Low Revenue'
      WHEN squaremeters BETWEEN 1000 AND 2000 AND revenue >= 300000
        THEN '4 - Medium Store - High Revenue'

      WHEN squaremeters > 2000 AND revenue < 500000
        THEN '5 - Large Store - Low Revenue'
      WHEN squaremeters > 2000 AND revenue >= 500000
        THEN '6 - Large Store - High Revenue'
      WHEN squaremeters IS NULL THEN '7 - Online Store'
  END AS store_category,
  ROUND(SUM(revenue)::numeric, 2) AS total_revenue,
  ROUND((SUM(revenue)::numeric / (SELECT SUM(revenue)::numeric FROM store_revenue)) * 100, 2) AS percentage_contribution
FROM
  store_revenue
GROUP BY
  store_category
ORDER BY
  store_category