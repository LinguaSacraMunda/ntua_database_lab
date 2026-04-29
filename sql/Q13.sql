WITH RECURSIVE supervisor AS (
    SELECT
        AMKA AS anchor,
        AMKA,
        rank,
        supervisor_id,
        0 AS step
    FROM doctor
    WHERE supervisor_id IS NOT NULL

    UNION ALL

    SELECT
        s.anchor,
        d.AMKA,
        d.rank,
        d.supervisor_id,
        s.step + 1 AS step
    FROM supervisor s
    INNER JOIN doctor d ON d.AMKA = s.supervisor_id
)
SELECT 
    AMKA,
    rank,
    supervisor_id,
    step
FROM supervisor
ORDER BY anchor, step;
