WITH MasterData AS (
  WITH LatestPerformance AS (
    SELECT
      employee_id,
      performance_score,
      potential_score,
      ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY review_date DESC) AS rn
    FROM
      `project-equilibrium-474307.hr_analytics.performance`
  )
  SELECT
    e.employee_id,
    lp.performance_score,
    lp.potential_score,
    CASE WHEN e.termination_date IS NOT NULL THEN 1 ELSE 0 END AS is_attrited
  FROM
    `hr_analytics.employees` AS e
  LEFT JOIN
    LatestPerformance AS lp
      ON e.employee_id = lp.employee_id AND lp.rn=1
),
TalentSegments AS (
  SELECT
    employee_id,
    is_attrited,
    CASE
      WHEN performance_score >= 4 AND potential_score >= 4 THEN 'Top Talent'
      WHEN performance_score >= 4 THEN 'High Performer'
      WHEN performance_score >= 4 THEN 'High Potential'
      ELSE 'Core Performaer'
    END AS talent_segment
  FROM MasterData
  WHERE performance_score IS NOT NULL AND potential_score IS NOT NULL
)
SELECT
  talent_segment,
  COUNT(employee_id) AS total_employees,
  ROUND(AVG(is_attrited)* 100,1) AS attrition_rate_percent
FROM
  TalentSegments
GROUP BY
  talent_segment
ORDER BY
  attrition_rate_percent DESC;