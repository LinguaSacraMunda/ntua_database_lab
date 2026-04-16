/*
SQL script για τη φόρτωση της βάσης με δεδομένα
*/

--
-- Doctor specialisation
--

LOAD DATA LOCAL INFILE 'data/042026_Specialty_Restrictions_AHP_MP.csv'
INTO TABLE specialisation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(spec_code, description_eng, description_grc);

--
-- KEN codes
--

LOAD DATA LOCAL INFILE 'data/4.1 Λίστα Κλειστών Ενοποιημένων Νοσηλίων.csv'
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

LOAD DATA LOCAL INFILE 'data/4.2 Κωδικοί ICD-10 15-12-2011.csv'
INTO TABLE diagnosis 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(diag_id, description);

--
-- Medical procedures
--

LOAD DATA LOCAL INFILE 'data/ΕΛΛΗΝΙΚΗ_ΟΝΟΜΑΤΟΛΟΓΙΑ_ΚΑΙ_ΚΩΔΙΚΟΠΟΙΗΣΗ_ΤΩΝ_ΙΑΤΡΙΚΩΝ_ΠΡΑΞΕΩΝ.csv'
INTO TABLE medical_procedure 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 2 ROWS
(med_proc_id, med_proc_code, description);


--
--  Pharmaceutical products
--
/*
LOAD DATA LOCAL INFILE '/home/admin/shared_ntua/6th_semester/databases/project/data/act_subs_rem_dupl.csv'
INTO TABLE active_substance 
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(@hlpr)
SET act_sub_full = @hlpr;
*/

-- =========================================
-- 0. SAFETY SETTINGS
-- =========================================
SET FOREIGN_KEY_CHECKS = 0;
SET sql_mode = '';

-- =========================================
-- 1. STAGING TABLE (DROP + CREATE)
-- =========================================
DROP TABLE IF EXISTS staging_ema;

CREATE TABLE staging_ema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name TEXT,
    active_substances TEXT,
    routes TEXT,
    auth_country VARCHAR(100),
    marketing_auth_holder TEXT,
    master_file_loc VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =========================================
-- 2. LOAD CSV FILE
-- =========================================

LOAD DATA LOCAL INFILE 'data/article-57-product-data_en_clean.csv'
INTO TABLE staging_ema
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_name,
    active_substances,
    routes,
    auth_country,
    marketing_auth_holder,
    master_file_loc,
    email,
    phone
);

-- =========================================
-- 3. BASIC CLEANING
-- =========================================

UPDATE staging_ema
SET
    product_name = TRIM(product_name),
    active_substances = TRIM(active_substances),
    routes = TRIM(routes),
    auth_country = TRIM(auth_country),
    marketing_auth_holder = TRIM(marketing_auth_holder),
    master_file_loc = TRIM(master_file_loc),
    email = TRIM(email),
    phone = TRIM(phone);

DELETE FROM staging_ema
WHERE product_name IS NULL OR product_name = '';

-- =========================================
-- 4. INSERT PHARMACEUTICAL PRODUCTS
-- =========================================

INSERT INTO pharmaceutical_product
(name, auth_country, marketing_auth_holder, master_file_loc, email, phone)
SELECT DISTINCT
    product_name,
    auth_country,
    marketing_auth_holder,
    master_file_loc,
    email,
    phone
FROM staging_ema;

-- =========================================
-- 5. INSERT ACTIVE SUBSTANCES
-- =========================================

INSERT IGNORE INTO active_substance (act_sub_full)
SELECT DISTINCT TRIM(jt.value)
FROM staging_ema s
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(REPLACE(s.active_substances, '"', ''), '|', '","'), '"]'),
    '$[*]' COLUMNS (value TEXT PATH '$')
) jt
WHERE TRIM(jt.value) <> '';

-- =========================================
-- 6. Insert Routes of Administration
-- =========================================

INSERT IGNORE INTO route_of_admission (type)
SELECT DISTINCT TRIM(jt.value)
FROM staging_ema s
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(REPLACE(s.routes, '"', ''), ',', '","'), '"]'),
    '$[*]' COLUMNS (value TEXT PATH '$')
) jt
WHERE TRIM(jt.value) <> '';

-- =========================================
-- 6.1 Indices & Procedure
-- =========================================

CREATE INDEX idx_prod_name ON pharmaceutical_product(name);
CREATE INDEX idx_sub_name ON active_substance(act_sub_full(100));
CREATE INDEX idx_route_name ON route_of_admission(type);

ALTER TABLE staging_ema 
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE pharmaceutical_product 
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE active_substance 
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE route_of_admission 
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

DELIMITER $$

CREATE PROCEDURE load_product_act_sub_fast(IN batch_size INT)
BEGIN
    DECLARE last_id INT DEFAULT 0;
    DECLARE max_id INT;

    SELECT MAX(id) INTO max_id FROM staging_ema;

    DROP TEMPORARY TABLE IF EXISTS tmp_product_substances;
    CREATE TEMPORARY TABLE tmp_product_substances (
        product_name VARCHAR(255),
        substance VARCHAR(255),
        INDEX idx_prod (product_name),
        INDEX idx_sub (substance)
    ) ENGINE=InnoDB;

    WHILE last_id < max_id DO

        TRUNCATE TABLE tmp_product_substances;

        INSERT INTO tmp_product_substances (product_name, substance)
        SELECT
            s.product_name,
            TRIM(jt.value)
        FROM staging_ema s
        JOIN JSON_TABLE(
            CONCAT('["', REPLACE(REPLACE(s.active_substances, '"', ''), '|', '","'), '"]'),
            '$[*]' COLUMNS (value TEXT PATH '$')
        ) jt
        WHERE s.id > last_id
        ORDER BY s.id
        LIMIT batch_size;

        -- Deduplicate
        CREATE TEMPORARY TABLE tmp_distinct AS
        SELECT DISTINCT product_name, substance
        FROM tmp_product_substances;

        DROP TEMPORARY TABLE tmp_product_substances;
        RENAME TABLE tmp_distinct TO tmp_product_substances;

        ALTER TABLE tmp_product_substances
        ADD INDEX idx_prod (product_name),
        ADD INDEX idx_sub (substance);

        INSERT IGNORE INTO product_act_sub (act_sub_id, pharm_prod_id)
        SELECT
            a.act_sub_id,
            p.pharm_prod_id
        FROM tmp_product_substances t
        JOIN pharmaceutical_product p
            ON p.name = t.product_name
        JOIN active_substance a
            ON a.act_sub_full = t.substance;

        -- advance batch
        SELECT MAX(id) INTO last_id
        FROM staging_ema
        WHERE id > last_id
        LIMIT batch_size;

    END WHILE;

END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE load_product_route_fast(IN batch_size INT)
BEGIN
    DECLARE last_id INT DEFAULT 0;
    DECLARE max_id INT;

    SELECT MAX(id) INTO max_id FROM staging_ema;

    DROP TEMPORARY TABLE IF EXISTS tmp_product_routes;
    CREATE TEMPORARY TABLE tmp_product_routes (
        product_name VARCHAR(255),
        route VARCHAR(255),
        INDEX idx_prod (product_name),
        INDEX idx_route (route)
    ) ENGINE=InnoDB;

    WHILE last_id < max_id DO

        TRUNCATE TABLE tmp_product_routes;

        INSERT INTO tmp_product_routes (product_name, route)
        SELECT
            s.product_name,
            TRIM(jt.value)
        FROM staging_ema s
        JOIN JSON_TABLE(
            CONCAT('["', REPLACE(REPLACE(s.routes, '"', ''), ',', '","'), '"]'),
            '$[*]' COLUMNS (value TEXT PATH '$')
        ) jt
        WHERE s.id > last_id
        ORDER BY s.id
        LIMIT batch_size;

        -- Deduplicate
        CREATE TEMPORARY TABLE tmp_distinct AS
        SELECT DISTINCT product_name, route
        FROM tmp_product_routes;

        DROP TEMPORARY TABLE tmp_product_routes;
        RENAME TABLE tmp_distinct TO tmp_product_routes;

        ALTER TABLE tmp_product_routes
        ADD INDEX idx_prod (product_name),
        ADD INDEX idx_route (route);

        INSERT IGNORE INTO product_route (route_id, pharm_prod_id)
        SELECT
            r.route_id,
            p.pharm_prod_id
        FROM tmp_product_routes t
        JOIN pharmaceutical_product p
            ON p.name = t.product_name
        JOIN route_of_admission r
            ON r.type = t.route;

        -- advance batch
        SELECT MAX(id) INTO last_id
        FROM staging_ema
        WHERE id > last_id
        LIMIT batch_size;

    END WHILE;

END$$

DELIMITER ;


-- =========================================
-- 7. LINK PRODUCT ↔ ACTIVE SUBSTANCE
-- =========================================

CALL load_product_act_sub_fast(1000);

-- =========================================
-- 8. LINK PRODUCT ↔ ROUTE
-- =========================================

CALL load_product_route_fast(1000);

-- =========================================
-- 9. CLEANUP + RESTORE SETTINGS
-- =========================================
DROP TABLE staging_ema;
DROP TABLE tmp_product_routes;
DROP TABLE tmp_product_substances;
SET FOREIGN_KEY_CHECKS = 1;

