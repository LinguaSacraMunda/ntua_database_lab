WITH 
    patient_rec_hlpr(patient_id, hosp_id) AS ( 
            SELECT *
            FROM patient_record
            WHERE AMKA IN (
                        SELECT AMKA
                        FROM patient_record
                        GROUP BY AMKA
                        HAVING COUNT(hosp_id) >= 2)
        )
SELECT prh.patient_id, h.dept_name, calculate_hospit_cost(h.hosp_id) AS total_cost
FROM patient_rec_hlpr prh
INNER JOIN hospitalisation h on h.hosp_id = prh.hosp_id
GROUP BY prh.patient_id, h.dept_name
HAVING COUNT(*) >= 2;
