WITH EmployeeTenure AS (
  SELECT
    employee_id,
    department,
    CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END AS is_attrited,
    DATE_DIFF(
      COALESCE(termination_date, CURRENT_DATE()),
      hire_date,
      DAY
    ) AS tenure_in_days
  FROM `project-equilibrium-474307.hr_analytics.employees`
)
SELECT
  department,
  COUNT(employee_id) AS total_employees,
  ROUND(AVG(tenure_in_days) / 365.25,1) AS average_tenure_years,
  SUM(CASE WHEN is_attrited = 0 THEN 1 ELSE 0 END) AS current_headcount
FROM
  EmployeeTenure
GROUP BY
  department
ORDER BY
  current_headcount DESC;