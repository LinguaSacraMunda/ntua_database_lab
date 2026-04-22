SELECT 
    ds.dept_name,
    s.day,
    count(d.AMKA) AS doctors_not_in_shift
FROM doctor d, dept_shift ds
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
GROUP BY ds.dept_name, s.day




SELECT 
    ds.dept_name,
    s.day,
    s.type,
    count(d.AMKA) AS nurses_not_in_shift
FROM nurse d, dept_shift ds
INNER JOIN shift s ON ds.shift_id = s.shift_id
WHERE 
    s.status = 1
  AND
    d.AMKA NOT IN (
        SELECT dcs_t.AMKA
        FROM dept_shift ds_t
        INNER JOIN shift s_t ON ds_t.shift_id = s_t.shift_id
        INNER JOIN nurse_shift dcs_t ON ds_t.shift_id = dcs_t.shift_id
        WHERE s_t.status = 1
          AND s_t.day = s.day
          AND s_t.type = s.type
    )
GROUP BY ds.dept_name, s.day, s.type




SELECT 
    ds.dept_name,
    s.day,
    s.type,
    count(d.AMKA) AS admin_staff_not_in_shift
FROM administrative_staff d, dept_shift ds
INNER JOIN shift s ON ds.shift_id = s.shift_id
WHERE 
    s.status = 1
  AND
    d.AMKA NOT IN (
        SELECT dcs_t.AMKA
        FROM dept_shift ds_t
        INNER JOIN shift s_t ON ds_t.shift_id = s_t.shift_id
        INNER JOIN admin_shift dcs_t ON ds_t.shift_id = dcs_t.shift_id
        WHERE s_t.status = 1
          AND s_t.day = s.day
          AND s_t.type = s.type
    )
GROUP BY ds.dept_name, s.day, s.type
