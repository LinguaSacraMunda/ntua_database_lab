SELECT d.AMKA, d.first_name, d.last_name, 
    TIMESTAMPDIFF(YEAR, d.date_of_birth, NOW()) AS age,
    COUNT(sa.med_act_id) AS num_of_surgeries
FROM surgical_act sa
INNER JOIN doctor d ON sa.primary_doc_id = d.AMKA
WHERE d.date_of_birth >= DATE_SUB(NOW(), INTERVAL 35 YEAR)
GROUP BY d.AMKA, d.first_name, d.last_name
ORDER BY num_of_surgeries DESC;
