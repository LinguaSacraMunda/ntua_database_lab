SELECT AMKA, AVG(medical_care), AVG(experience)
FROM (

SELECT lt.doc_id as AMKA, medical_care, experience
FROM 
    hospitalisation h
    INNER JOIN hosp_lab_test hlt ON h.hosp_id = hlt.hosp_id
    INNER JOIN lab_test lt ON hlt.lab_test_id = lt.lab_test_id
    INNER JOIN rating r ON h.hosp_id = r.hosp_id

UNION ALL

SELECT sa.primary_doc_id as AMKA, medical_care, experience
FROM
    hospitalisation h
    INNER JOIN hosp_med_act hma ON h.hosp_id = hma.hosp_id
    INNER JOIN surgical_act sa ON hma.med_act_id = sa.med_act_id
    INNER JOIN rating r ON h.hosp_id = r.hosp_id

UNION ALL

SELECT sada.assistant_id as AMKA, medical_care, experience
FROM
    hospitalisation h
    INNER JOIN hosp_med_act hma ON h.hosp_id = hma.hosp_id
    INNER JOIN surgical_act_doctor_assistants sada ON hma.med_act_id = sada.med_act_id
    INNER JOIN rating r ON h.hosp_id = r.hosp_id
) as hlpr
GROUP BY AMKA
