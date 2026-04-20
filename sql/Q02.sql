SELECT UNIQUE
    RTRIM(d.description_grc),
    d.AMKA, 
    d.first_name,
    d.last_name,
    EXISTS (SELECT *
            FROM doctor_shift ds
            INNER JOIN shift s ON s.shift_id = ds.shift_id
            WHERE YEAR(s.day) = YEAR(NOW())) 'Has shift this year',
    (SELECT COUNT(*) 
            FROM 
                surgical_act sat 
                INNER JOIN medical_act mat ON sat.med_act_id = mat.med_act_id 
            WHERE  d.AMKA = sat.primary_doc_id
                   AND YEAR(mat.start_datetime) = YEAR(NOW())) 'Number of Surgeries Conducted as Primary Doctor'
FROM 
    vw_doctor_info d
ORDER BY d.description_grc, d.AMKA, d.first_name, d.last_name;
