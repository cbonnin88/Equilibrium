WITH MasterData AS (
  WITH LatestPerformance AS (
    SELECT
      employee_id,
      performance_score,
      ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY review_date DESC) AS rn
    FROM
      `hr_analytics.performance`
  )
  SELECT
    e.employee_id,
    lp.performance_score,
    CASE WHEN e.termination_date IS NOT NULL THEN 1 ELSE 0 END AS is_attrited
  FROM
    `hr_analytics.employees` AS e
  LEFT JOIN
    LatestPerformance AS lp
      ON e.employee_id = lp.employee_id AND lp.rn = 1
)
SELECT
  performance_score,
  COUNT(employee_id) AS total_employees,
  ROUND(AVG(is_attrited) * 100,0) AS attrition_rate_percent
FROM
  MasterData
WHERE
  performance_score IS NOT NULL
GROUP BY
  performance_score
ORDER BY
  performance_score ASC;