WITH FirstPromotion AS (
  SELECT
    employee_id,
    promotion_date,
    ROW_NUMBER() OVER(PARTITION BY employee_id ORDER BY promotion_date ASC) AS rn
  FROM
    `project-equilibrium-474307.hr_analytics.job_history`
)
SELECT
  e.department,
  COUNT(fp.employee_id) AS number_of_promoted_employees,
  ROUND(AVG(DATE_DIFF(fp.promotion_date, e.hire_date,MONTH)),1) AS avg_months_to_first_promo
FROM
  `hr_analytics.employees` AS e
JOIN
  FirstPromotion AS fp
    ON e.employee_id = fp.employee_id
WHERE
  fp.rn = 1
GROUP BY  
  e.department
ORDER BY
  avg_months_to_first_promo ASC;