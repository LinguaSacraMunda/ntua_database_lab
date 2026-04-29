SELECT
    pr.AMKA,
    hlpr.act_sub_1,
    hlpr.act_sub_2,
    hlpr.pair_count
FROM patient_record pr
INNER JOIN (
    SELECT 
        hp.hosp_id,
        pas1.act_sub_id AS act_sub_1,
        pas2.act_sub_id AS act_sub_2,
        COUNT(*) AS pair_count
    FROM hosp_prescription hp
    INNER JOIN prescribed_products pp1 ON hp.prescription_id = pp1.prescription_id
    INNER JOIN prescribed_products pp2 ON hp.prescription_id = pp2.prescription_id
    INNER JOIN product_act_sub pas1 ON pp1.pharm_prod_id = pas1.pharm_prod_id
    INNER JOIN product_act_sub pas2 ON pp2.pharm_prod_id = pas2.pharm_prod_id
    WHERE pas1.act_sub_id < pas2.act_sub_id
    AND pp1.pharm_prod_id <> pp2.pharm_prod_id
    AND pp1.start_date <= pp2.end_date
    AND pp2.start_date <= pp1.end_date
    GROUP BY pas1.act_sub_id, pas2.act_sub_id
    ORDER BY pair_count DESC, hosp_id ASC
    LIMIT 3) hlpr
ON pr.hosp_id = hlpr.hosp_id;
