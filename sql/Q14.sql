WITH hlpr AS (
    SELECT
        YEAR(h.admission_date) AS year,
        ad.diag_id,
        COUNT(*) AS cnt
    FROM hospitalisation h
    INNER JOIN admission_diagnosis ad ON ad.hosp_id = h.hosp_id
    GROUP BY year, ad.diag_id

    UNION ALL

    SELECT
        YEAR(h.admission_date) AS year,
        dd.diag_id,
        COUNT(*) AS cnt
    FROM hospitalisation h
    INNER JOIN discharge_diagnosis dd ON dd.hosp_id = h.hosp_id
    GROUP BY year, dd.diag_id
    ),
    codes_yearly AS (
    SELECT year, diag_id, SUM(cnt) as cnt
    FROM hlpr
    GROUP BY year, diag_id
    )
SELECT A.year, B.year AS prev_year, A.diag_id, A.cnt AS count
FROM codes_yearly A
INNER JOIN codes_yearly B 
        ON A.year - 1 = B.year 
       AND A.diag_id = B.diag_id
       AND A.cnt = B.cnt
WHERE A.cnt >= 5;
