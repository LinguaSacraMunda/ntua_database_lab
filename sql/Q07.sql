SELECT hlpr1.act_sub_id, patients_allergic_to_sub, products_containing_sub
FROM (
SELECT acts.act_sub_id, count(*) AS patients_allergic_to_sub
FROM
    active_substance acts
    INNER JOIN patient_allergy pa ON acts.act_sub_id = pa.act_sub_id
GROUP BY acts.act_sub_id
) hlpr1
JOIN (
SELECT acts.act_sub_id, count(*) AS products_containing_sub
FROM
    active_substance acts
    INNER JOIN product_act_sub pas ON acts.act_sub_id = pas.act_sub_id
GROUP BY acts.act_sub_id
) hlpr2 ON hlpr1.act_sub_id = hlpr2.act_sub_id
ORDER BY patients_allergic_to_sub DESC;
