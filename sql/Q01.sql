SELECT 
    h.dept_name 'Department',
    YEAR(h.admission_date) 'Year',
    c.KEN_code KEN,
    i.name 'Insurance Carrier', 
    COUNT(h.costing_id) 'Cases covered by carrier', 
    SUM(c.base_cost) 'Total base cost',
    SUM(calculate_hospit_cost(h.hosp_id)) 'Total revenue'
FROM 
    hospitalisation h
    INNER JOIN costing c ON h.costing_id = c.costing_id
    INNER JOIN insurance_carrier i ON h.carrier_id = i.carrier_id
GROUP BY h.dept_name, YEAR(h.admission_date), c.KEN_code, i.carrier_id;
