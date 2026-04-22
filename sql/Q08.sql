SELECT
    ds.dept_name,
    s.day,
    count(d.AMKA) AS doctors_not_in_shift
FROM doctor d
INNER JOIN dept_shift ds ON ds.shift_id = dcs.shift_id
INNER JOIN shift s ON ds.shift_id = s.shift_id
WHERE 
    s.status = 1
  AND
    d.AMKA NOT IN (
        SELECT dcs_t.AMKA
        FROM dept_shift ds_t
        INNER JOIN shift s_t ON ds_t.shift_id = s_t.shift_id
        INNER JOIN doctor_shift dcs_t ON ds_t.shift_id = dcs_t.shift_id
        WHERE s_t.status = 1
          AND s_t.day = s.day
    )
group by ds.dept_name, s.day



WITH dept_day AS (
    SELECT DISTINCT ds.dept_name, s.day
    FROM dept_shift ds
    INNER JOIN shift s ON ds.shift_id = s.shift_id
    WHERE s.status = 1
)
SELECT 
    dd.dept_name,
    dd.day,
    d.AMKA AS doctors_not_on_call
FROM dept_day dd
CROSS JOIN doctor d
WHERE NOT EXISTS (
    SELECT *
    FROM doctor_shift dcs
    INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
    INNER JOIN shift s ON ds.shift_id = s.shift_id
    WHERE dcs.AMKA = d.AMKA
      AND ds.dept_name = dd.dept_name
      AND s.day = dd.day
      AND s.status = 1
)
