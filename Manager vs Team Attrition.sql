WITH MasterData AS (
  SELECT
    department,
    job_level,
    CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END AS is_attrited,
    CASE WHEN job_level = 'Manager' THEN 1 ELSE 0 END AS is_manager
  FROM
    `hr_analytics.employees`
)
SELECT
  department,
  AVG(CASE WHEN is_manager = 1 THEN is_attrited END) * 100 AS manager_attrition_rate,
  AVG(CASE WHEN is_manager = 0 THEN is_attrited END) * 100 AS team_attrition_rate
FROM
  MasterData
GROUP BY
  department
HAVING
  manager_attrition_rate IS NOT NULL
ORDER BY
  team_attrition_rate DESC