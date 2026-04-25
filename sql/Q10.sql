

-- All possible combinations of active substances
SELECT *
FROM 
    (SELECT pas_t.act_sub_id
    FROM hosp_prescription hp_t
    INNER JOIN prescribed_products pp_t ON hp_t.prescription_id = pp_t.prescription_id
    INNER JOIN product_act_sub pas_t ON pp_t.pharm_prod_id = pas_t.pharm_prod_id
    WHERE hp_t.hosp_id = 100) A
INNER JOIN 
    (SELECT pas_t.act_sub_id
    FROM hosp_prescription hp_t
    INNER JOIN prescribed_products pp_t ON hp_t.prescription_id = pp_t.prescription_id
    INNER JOIN product_act_sub pas_t ON pp_t.pharm_prod_id = pas_t.pharm_prod_id
    WHERE hp_t.hosp_id = 100) B
ON A.act_sub_id < B.act_sub_id
ORDER BY A.act_sub_id
