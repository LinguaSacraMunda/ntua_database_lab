WITH 
    -- Find all days on which some department
    -- has valid shifts
    dept_day AS (
        SELECT DISTINCT ds.dept_name, s.day
        FROM dept_shift ds
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE s.status = 1
    ),

    -- Find all staff not any shifts per department and day
    staff_not_on_call AS (
        SELECT
            dd.dept_name,
            dd.day,
            'Doctor' AS role,
            d.AMKA
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
        
        UNION ALL

        SELECT
            dd.dept_name,
            dd.day,
            'Nurse' AS role,
            d.AMKA
        FROM dept_day dd
        CROSS JOIN nurse d
        WHERE NOT EXISTS (
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
            d.AMKA
        FROM dept_day dd
        CROSS JOIN administrative_staff d
        WHERE NOT EXISTS (
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
SELECT *
FROM staff_not_on_call
ORDER BY dept_name, day, role, AMKA;
