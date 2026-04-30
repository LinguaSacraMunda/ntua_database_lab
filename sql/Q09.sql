WITH
    mult_day_instances AS (
        SELECT TIMESTAMPDIFF(DAY, h.admission_date, h.discharge_date) as days
        FROM hospitalisation h
        INNER JOIN patient_record pr ON h.hosp_id = pr.hosp_id
        WHERE h.discharge_date IS NOT NULL 
        AND h.admission_date >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
        AND TIMESTAMPDIFF(DAY, h.admission_date, h.discharge_date) >= 15
        GROUP BY days
        HAVING count(*) > 1
    )
SELECT mdi.days, pr.AMKA AS patient_AMKA, h.hosp_id
FROM hospitalisation h
INNER JOIN patient_record pr ON h.hosp_id = pr.hosp_id
INNER JOIN mult_day_instances mdi 
        ON mdi.days = TIMESTAMPDIFF(DAY, h.admission_date, h.discharge_date)
WHERE h.discharge_date IS NOT NULL 
  AND h.admission_date >= DATE_SUB(NOW(), INTERVAL 1 YEAR)
  AND TIMESTAMPDIFF(DAY, h.admission_date, h.discharge_date) >= 15
ORDER BY days;
