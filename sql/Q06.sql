SELECT 
    pr.AMKA, 
    h.hosp_id, 
    calculate_hospit_cost(h.hosp_id) AS cost, 
    ad.diag_id as admission_diagnosis, 
    dd.diag_id as discharge_diagnosis, 
    (r.medical_care + r.nursing_care + r.cleanliness + r.food + r.experience) / 5 AS avg_rating
FROM patient_record pr
INNER JOIN hospitalisation h ON h.hosp_id = pr.hosp_id
INNER JOIN admission_diagnosis ad ON h.hosp_id = ad.hosp_id
LEFT JOIN discharge_diagnosis dd ON h.hosp_id = dd.hosp_id
LEFT JOIN rating r ON h.hosp_id = r.hosp_id
ORDER BY pr.AMKA;
