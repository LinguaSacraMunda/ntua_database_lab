SELECT
    t.level,
    IF (h.dept_name IS NOT NULL, h.dept_name, 'N/A') AS dept_name,
    COUNT(*) AS count,
    AVG(TIMESTAMPDIFF(MINUTE, t.arrival_time, h.admission_date)) AS 'avg_wait_time (min)',
    100 * COUNT(*) / (SELECT COUNT(*) FROM triage WHERE level = t.level) AS hosp_per_cent
FROM triage t
LEFT JOIN hospitalisation h ON t.triage_id = h.triage_id
GROUP BY t.level, h.dept_name;
