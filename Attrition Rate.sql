WITH AttritionData AS (
  SELECT
    department,
    CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END AS is_attrited
  FROM
    `hr_analytics.employees`
)
SELECT
  department,
  ROUND(AVG(is_attrited) * 100,0) AS attrition_rate_percent
FROM
  AttritionData
GROUP BY
  department
ORDER BY
  attrition_rate_percent DESC;