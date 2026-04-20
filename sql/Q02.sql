SELECT d.description_grc, d.AMKA, 
EXISTS (SELECT * FROM surgical_act sat ON d.AMKA = sat.primary_doc_id INNER JOIN medical_act mat ON sat.med_act_id = mat.med_act_id WHERE YEAR(mat.start_datetime) = YEAR(NOW())), 
    sa.primary_doc_id
FROM vw_doctor_info d
INNER JOIN doctor_shift ds ON d.AMKA = ds.AMKA
INNER JOIN shift s ON s.shift_id = ds.shift_id
INNER JOIN surgical_act sa ON sa.primary_doc_id = d.AMKA
WHERE YEAR(s.day) = YEAR(NOW())
ORDER BY d.spec_code, d.AMKA;
