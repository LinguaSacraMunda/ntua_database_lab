SELECT d.AMKA, COUNT(*) AS surgery_count
FROM doctor d
INNER JOIN surgical_act sa ON d.AMKA = sa.primary_doc_id
INNER JOIN medical_act ma on sa.med_act_id = ma.med_act_id
WHERE YEAR(NOW()) = YEAR(ma.start_datetime)
GROUP BY d.AMKA
HAVING COUNT(*) <= (
    SELECT MAX(cnt) - 5
    FROM (
        SELECT COUNT(*) AS cnt
        FROM surgical_act sa_t
        INNER JOIN medical_act ma_t ON sa_t.med_act_id = ma_t.med_act_id
        WHERE YEAR(NOW()) = YEAR(ma_t.start_datetime)
        GROUP BY sa_t.primary_doc_id
    ) hlpr
)
ORDER BY surgery_count DESC;
