SELECT *
FROM prescribed_products pp
INNER JOIN product_act_sub pas ON pp.pharm_prod_id = pas.pharm_prod_id
WHERE pas.act_sub_id IN (
    SELECT pas_.act_sub_id
    FROM prescribed_products pp_t
    INNER JOIN product_act_sub pas ON pp_t.pharm_prod_id = pas_t.pharm_prod_id
    WHERE pp_t.hosp_id = pp.hosp_id
    GROUP BY pp.prescription_id, pas.act_sub_id)
