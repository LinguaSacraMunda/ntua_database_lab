WITH 
    -- Find all days on which some department
    -- has valid shifts within a given week
    -- note that 2026-04-29 11:10:17 is the 
    -- result of NOW() as of writing this
    dept_day AS (
        SELECT DISTINCT ds.dept_name, s.day
        FROM dept_shift ds
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE s.status = 1
          AND s.day BETWEEN DATE_SUB('2026-04-29 11:10:17', INTERVAL 7 DAY)
                        AND '2026-04-29 11:10:17'
    ),

    -- Find all staff per department and day
    staff_on_call AS (
        SELECT
            dd.dept_name,
            dd.day,
            'Doctor' AS role,
            ds.spec_code AS type,
            d.AMKA
        FROM dept_day dd
        CROSS JOIN doctor d
        INNER JOIN doc_spec ds ON d.AMKA = ds.AMKA
        WHERE EXISTS (
                SELECT *
                FROM doctor_shift dcs
                INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
                INNER JOIN shift s ON ds.shift_id = s.shift_id
                WHERE dcs.AMKA = d.AMKA
                AND ds.dept_name = dd.dept_name
                AND s.day = dd.day
                AND s.status = 1
            )
        
        UNION ALL

        SELECT
            dd.dept_name,
            dd.day,
            'Nurse' AS role,
            d.rank AS type,
            d.AMKA
        FROM dept_day dd
        CROSS JOIN nurse d
        WHERE EXISTS (
                SELECT *
                FROM nurse_shift dcs
                INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
                INNER JOIN shift s ON ds.shift_id = s.shift_id
                WHERE dcs.AMKA = d.AMKA
                AND ds.dept_name = dd.dept_name
                AND s.day = dd.day
                AND s.status = 1
            )

        UNION ALL

        SELECT
            dd.dept_name,
            dd.day,
            'Admin' AS role,
            d.role AS type,
            d.AMKA
        FROM dept_day dd
        CROSS JOIN administrative_staff d
        WHERE EXISTS (
                SELECT *
                FROM admin_shift dcs
                INNER JOIN dept_shift ds ON dcs.shift_id = ds.shift_id
                INNER JOIN shift s ON ds.shift_id = s.shift_id
                WHERE dcs.AMKA = d.AMKA
                AND ds.dept_name = dd.dept_name
                AND s.day = dd.day
                AND s.status = 1
            )
    )
SELECT 
    dept_name,
    day,
    role,
    type,
    COUNT(*)
FROM staff_on_call
GROUP BY dept_name, day, role, type;
