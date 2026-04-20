SELECT d.dept_name as 'Department', YEAR(h.admission_date) as 'Year', i.name as 'Insurance Carrier', COUNT(h.costing_id) as 'Cases covered by carrier', SUM(c.base_cost) as 'Total base cost'
FROM hospitalisation h
INNER JOIN costing c ON h.costing_id = c.costing_id
INNER JOIN department d ON h.dept_name = d.dept_name
INNER JOIN insurance_carrier i ON h.carrier_id = i.carrier_id
GROUP BY h.dept_name, YEAR(h.admission_date), i.carrier_id;
