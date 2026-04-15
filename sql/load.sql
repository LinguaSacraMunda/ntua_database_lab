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
(KEN_code, description, @hlpr, mean_hospit_time)
SET base_cost = REPLACE(@hlpr, ' ', '');

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

--
-- Medical procedures
--

LOAD DATA LOCAL INFILE '/home/admin/shared_ntua/6th_semester/databases/project/TEMP/ΕΛΛΗΝΙΚΗ_ΟΝΟΜΑΤΟΛΟΓΙΑ_ΚΑΙ_ΚΩΔΙΚΟΠΟΙΗΣΗ_ΤΩΝ_ΙΑΤΡΙΚΩΝ_ΠΡΑΞΕΩΝ.csv'
INTO TABLE medical_procedure 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS
(med_proc_id, med_proc_code, description);


--
--  Pharmaceutical products
--

LOAD DATA LOCAL INFILE '/home/admin/shared_ntua/6th_semester/databases/project/TEMP/act_subs_rem_dupl.csv'
INTO TABLE active_substance 
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@hlpr)
SET act_sub_full = @hlpr, act_sub = LEFT(@hlpr, 100);

