WITH cohorts_year AS(
    SELECT
        customerkey,
        EXTRACT(YEAR FROM MIN(orderdate)) AS cohort_year
    FROM sales
    GROUP BY
      customerkey
),
monthly_stats AS (
  SELECT
        TO_CHAR(DATE_TRUNC('month', s.orderdate), 'YYYY-MM-DD') AS order_month,
        COUNT(DISTINCT s.orderkey) AS total_orders,
        COUNT(DISTINCT s.customerkey) AS user_count
    FROM sales s
    JOIN cohorts_year c ON
      s.customerkey = c.customerkey
    GROUP BY -- we group by both year and month because we want to do cohort analysis, since the orderdate's year may not match the cohort year, but we want the separate
      cohort_year,
      order_month
)
SELECT *,
  ROW_NUMBER() OVER(
      ORDER BY
        total_orders DESC
  ) AS total_orders_row_num,

  RANK() OVER(
      ORDER BY
        total_orders DESC
  ) AS total_orders_rank,

  DENSE_RANK() OVER(
      ORDER BY
        total_orders DESC
  ) AS total_orders_dense_rank
FROM monthly_stats
ORDER BY total_orders DESC;