WITH LatestCompensation AS (
  SELECT
    employee_id,
    base_salary,
    ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY effective_date DESC) AS rn
  FROM
    `project-equilibrium-474307.hr_analytics.compensation`
),
LatestPerformance AS (
  SELECT
    employee_id,
    performance_score,
    ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY review_date DESC) AS rn
  FROM
    `hr_analytics.performance`
),
CompensationPercentiles AS (
  SELECT
    e.employee_id,
    PERCENT_RANK() OVER(PARTITION BY e.department, e.job_level ORDER BY lc.base_salary) * 100 AS salary_percentile
  FROM
    `hr_analytics.employees` AS e
  LEFT JOIN LatestCompensation AS lc
    ON e.employee_id = lc.employee_id AND lc.rn = 1
)
SELECT
  e.employee_id,
  e.department,
  e.job_level,
  (
    CASE WHEN lp.performance_score <= 2 THEN 2 ELSE 0 END +
    CASE WHEN cp.salary_percentile < 25 THEN 2 ELSE 0 END +
    CASE WHEN DATE_DIFF(CURRENT_DATE(), e.hire_date,MONTH) BETWEEN 12 AND 36 THEN 1 ELSE 0 END
  ) AS flight_risk_score,
  lp.performance_score,
  cp.salary_percentile
FROM
  `hr_analytics.employees` AS e
LEFT JOIN 
  LatestPerformance AS lp
    ON e.employee_id = lp.employee_id AND lp.rn=1
LEFT JOIN
  CompensationPercentiles AS cp
    ON e.employee_id = cp.employee_id
WHERE
  e.termination_date IS NULL
ORDER BY
  flight_risk_score DESC,
  salary_percentile ASC
LIMIT 50; -- Showing the top 50 employees with the highest risk score
  