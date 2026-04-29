SELECT
    t.level,
    h.dept_name,
    COUNT(*) AS count,
    AVG(TIMESTAMPDIFF(MINUTE, t.arrival_time, h.admission_date)) AS 'avg_wait_time (min)',
    100 * COUNT(*) / (SELECT COUNT(*) FROM triage WHERE level = t.level) AS hosp_per_cent
FROM triage t
INNER JOIN hospitalisation h ON h.triage_id = t.triage_id
WHERE t.status = 1
GROUP BY t.level, h.dept_name;
