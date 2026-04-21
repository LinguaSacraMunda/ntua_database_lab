SELECT acts.act_sub_full, count(*) AS 'patients_allergic_to_sub'
FROM
    active_substance acts
    INNER JOIN patient_allergy pa ON acts.act_sub_id = pa.act_sub_id
GROUP BY acts.act_sub_full

SELECT acts.act_sub_full, count(*) AS products_containing_sub
FROM
    active_substance acts
    INNER JOIN product_act_sub pas ON acts.act_sub_id = pas.act_sub_id
GROUP BY acts.act_sub_full
