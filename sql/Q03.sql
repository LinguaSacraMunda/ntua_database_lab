WITH
    patient_rec_hlpr(patient_id, hosp_id) AS
        (
            SELECT all
                AMKA,
                hosp_id
            FROM
                patient_record
            GROUP BY AMKA
            HAVING COUNT(hosp_id) >= 3
        )
SELECT prh.patient_id, calculate_hospit_cost(h.hosp_id) AS total_cost
FROM patient_rec_hlpr prh
INNER JOIN patient_record pr ON pr.AMKA = prh.patient_id
INNER JOIN hospitalisation h ON h.hosp_id = pr.hosp_id
GROUP BY prh.patient_id, h.dept_name
HAVING count(*) >= 3
