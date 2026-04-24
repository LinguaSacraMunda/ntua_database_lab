SELECT pp.prescription_id, pas.act_sub_id, count(*)
FROM prescribed_products pp
INNER JOIN product_act_sub pas ON pp.pharm_prod_id = pas.pharm_prod_id
GROUP BY pp.prescription_id, pas.act_sub_id 
