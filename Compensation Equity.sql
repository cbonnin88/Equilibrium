WITH MasterData AS (
  WITH LatestCompensation AS (
    SELECT
      employee_id,
      base_salary,
      ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY effective_date DESC) AS rn
    FROM
      `hr_analytics.compensation`
  )
  SELECT
    e.employee_id,
    e.department,
    e.job_level,
    e.gender,
    lc.base_salary
  FROM
    `hr_analytics.employees` AS e
  LEFT JOIN
    LatestCompensation AS lc
      ON e.employee_id = lc.employee_id AND lc.rn = 1
)
SELECT
  employee_id,
  gender,
  department,
  job_level,
  base_salary,
  PERCENT_RANK() OVER(PARTITION BY department, job_level ORDER BY base_salary) * 100 AS salary_percentile
FROM
  MasterData
WHERE
  base_salary IS NOT NULL
ORDER BY
  salary_percentile ASC
LIMIT 20;