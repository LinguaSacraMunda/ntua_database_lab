/*
SQL script για τη φόρτωση της βάσης με δεδομένα
*/

--
-- Doctor specialisation
--

LOAD DATA LOCAL INFILE '/home/admin/shared_ntua/6th_semester/databases/project/TEMP/042026_Specialty_Restrictions_AHP_MP.csv'
INTO TABLE specialisation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(spec_code, description_eng, description_grc);

--
-- KEN codes
--

LOAD DATA LOCAL INFILE '/home/admin/shared_ntua/6th_semester/databases/project/TEMP/4.1 Λίστα Κλειστών Ενοποιημένων Νοσηλίων.csv'
INTO TABLE costing 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(KEN_code, description, @cost, mean_hospit_time)
SET base_cost = REPLACE(@cost, ' ', '');

--
-- ICD-10 codes
--

LOAD DATA LOCAL INFILE '/home/admin/shared_ntua/6th_semester/databases/project/TEMP/4.2 Κωδικοί ICD-10 15-12-2011.csv'
INTO TABLE diagnosis 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(diag_id, description);
