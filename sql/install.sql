/*
SQL script για τη δημιουργία του σχήματος της βάσης δεδομένων
*/

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';
-- show count(*) warnings;

DROP SCHEMA IF EXISTS ntua_db_2026;
CREATE SCHEMA ntua_db_2026;
USE ntua_db_2026;


--
--  Table structure for triage
--

CREATE TABLE triage (
    triage_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    level TINYINT(1) UNSIGNED NOT NULL CHECK (1 <= level AND level <= 5),
    arrival_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    symptoms TEXT NOT NULL,
    PRIMARY KEY (triage_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for patient
--

CREATE TABLE patient (
    AMKA VARCHAR(10) NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    date_of_birth DATE NOT NULL,
    sex  ENUM('male', 'female', 'other') NOT NULL,
    weight NUMERIC(5,2) NOT NULL DEFAULT 000.00 CHECK (weight >= 0),   -- in kg
    height NUMERIC(5,2) NOT NULL DEFAULT 000.00 CHECK (height >= 0),   -- in cm
    -- address
    street_name VARCHAR(45) DEFAULT NULL,
    street_number VARCHAR(45) DEFAULT NULL,
    postal_code VARCHAR(10) DEFAULT NULL,
    area VARCHAR(45) DEFAULT NULL,
    municipality VARCHAR(45) DEFAULT NULL,
    prefecture VARCHAR(45) DEFAULT NULL,
    -- address end
    profession VARCHAR(45) DEFAULT NULL,
    citizenship VARCHAR(45) DEFAULT NULL,

    triage_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA),
    INDEX idx_patient_last_name (last_name),
    CONSTRAINT fk_patient_triage FOREIGN KEY (triage_id) REFERENCES triage (triage_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE patient_email (
    AMKA VARCHAR(10) NOT NULL,
    email_address VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, email_address),
    CONSTRAINT fk_patient_email FOREIGN KEY (AMKA) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE patient_phone (
    AMKA VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (AMKA, phone_number),
    CONSTRAINT fk_patient_phone FOREIGN KEY (AMKA) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for emergency contact 
--

CREATE TABLE emergency_contact (
    patient_id VARCHAR(10) NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (patient_id, first_name, last_name, phone_number),
    CONSTRAINT fk_emergency_contact FOREIGN KEY (patient_id) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for nurse 
--

CREATE TABLE nurse (
    AMKA VARCHAR(10) NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_employment DATE NOT NULL CHECK (date_of_employment > date_of_birth),
    rank ENUM('Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος') NOT NULL,
    dept_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA),
    INDEX idx_nurse_last_name (last_name),
    CONSTRAINT fk_nurse_dept FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE nurse_email (
    AMKA VARCHAR(10) NOT NULL,
    email_address VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, email_address),
    CONSTRAINT fk_nurse_email FOREIGN KEY (AMKA) REFERENCES nurse (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE nurse_phone (
    AMKA VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (AMKA, phone_number),
    CONSTRAINT fk_nurse_phone FOREIGN KEY (AMKA) REFERENCES nurse (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Table structure for administrative staff 
--

CREATE TABLE administrative_staff (
    AMKA VARCHAR(10) NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_employment DATE NOT NULL CHECK (date_of_employment > date_of_birth),
    role ENUM('Γραμματεία', 'Λογιστήριο', 'Ανθρώπινο Δυναμικό', 'Τεχνική Υποστήριξη') NOT NULL,
    office VARCHAR(10) NOT NULL,
    dept_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA),
    INDEX idx_admin_last_name (last_name),
    CONSTRAINT fk_admin_dept FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE admin_email (
    AMKA VARCHAR(10) NOT NULL,
    email_address VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, email_address),
    CONSTRAINT fk_admin_email FOREIGN KEY (AMKA) REFERENCES administrative_staff (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE admin_phone (
    AMKA VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (AMKA, phone_number),
    CONSTRAINT fk_admin_phone FOREIGN KEY (AMKA) REFERENCES administrative_staff (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Table structure for doctor 
--

CREATE TABLE doctor (
    AMKA VARCHAR(10) NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_employment DATE NOT NULL CHECK (date_of_employment > date_of_birth),
    license_number VARCHAR(20) NOT NULL,
    rank ENUM('Ειδικευόμενος', 'Επιμελητής Β', 'Επιμελητής Α', 'Διευθυντής') NOT NULL,
    supervisor_id VARCHAR(10) NULL,
    PRIMARY KEY (AMKA),
    INDEX idx_doctor_last_name (last_name),
    CONSTRAINT fk_supervisor_id FOREIGN KEY (supervisor_id) REFERENCES doctor (AMKA) ON DELETE SET NULL ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE doctor_email (
    AMKA VARCHAR(10) NOT NULL,
    email_address VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, email_address),
    CONSTRAINT fk_doctor_email FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE doctor_phone (
    AMKA VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (AMKA, phone_number),
    CONSTRAINT fk_doctor_phone FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Doctor specialisation
--

CREATE TABLE specialisation (
    spec_code VARCHAR(7) NOT NULL,
    description_eng VARCHAR(100) NOT NULL,
    description_grc VARCHAR(100) NOT NULL,
    PRIMARY KEY (spec_code)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE doc_spec (
    AMKA VARCHAR(10) NOT NULL,
    spec_code VARCHAR(5) NOT NULL,
    PRIMARY KEY (AMKA, spec_code),
    CONSTRAINT fk_doctor_id FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_spec_id FOREIGN KEY (spec_code) REFERENCES specialisation (spec_code) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



--
-- Table structure for department
--

CREATE TABLE department (
    dept_name VARCHAR(45) NOT NULL,
    description TEXT NOT NULL,
    number_of_beds INT UNSIGNED NOT NULL DEFAULT 0,
    floor VARCHAR(5) NOT NULL,
    building VARCHAR(10) NOT NULL,
    director_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (dept_name),
    CONSTRAINT fk_dept_head FOREIGN KEY (director_id) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for doctor-department relation
--

CREATE TABLE doctor_dept (
    AMKA VARCHAR(10) NOT NULL,
    dept_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, dept_name),
    CONSTRAINT fk_doc_dept_doctor_id FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_doc_dept_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for beds
--

CREATE TABLE bed (
    bed_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type ENUM('ΜΕΘ', 'Μονόκλινο', 'Πολύκλινο', 'ΜΕΝΝ', 'Θάλαμος Νοσηλείας') NOT NULL,
    status ENUM('Διαθέσιμη', 'Κατειλημμένη', 'Υπό Συντήρηση') NOT NULL,
    dept_name VARCHAR(45) NOT NULL,
    room_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (bed_id),
    INDEX idx_bed_type (type),
    INDEX idx_bed_status (status),
    INDEX idx_fk_dept_name (dept_name),
    CONSTRAINT fk_bed_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bed_room_id FOREIGN KEY (room_id) REFERENCES room (room_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for room
--

CREATE TABLE room (
    room_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type ENUM('Κλίνες', 'Χειρουργική Αίθουσα', 'ΤΕΠ', 'Διαγνωστική Αίθουσα', 'Αίθουσα Αναμονής', 'Γραφείο', 'Αποθήκη') NOT NULL,
    status ENUM('Διαθέσιμο', 'Κατειλημμένο', 'Υπό Συντήρηση') NOT NULL,
    dept_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (room_id),
    INDEX idx_room_type (type),
    INDEX idx_room_status (status),
    INDEX idx_fk_dept_name (dept_name),
    CONSTRAINT fk_room_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for equipment
--

CREATE TABLE equipment (
    UID VARCHAR(128) NOT NULL,
    description TEXT NOT NULL,
    PRIMARY KEY (UID)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE equipment_room (
    UID VARCHAR(128) NOT NULL,
    room_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (UID),
    CONSTRAINT fk_equip_room_UID FOREIGN KEY (UID) REFERENCES equipment (UID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_equip_room_room_id FOREIGN KEY (room_id) REFERENCES room (room_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE equipment_dept (
    UID VARCHAR(128) NOT NULL,
    dept_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (UID),
    CONSTRAINT fk_equip_room_UID FOREIGN KEY (UID) REFERENCES equipment (UID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_equip_room_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for shift 
--

CREATE TABLE shift (
    shift_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    day DATE NOT NULL,
    type  ENUM('07:00-15:00', '15:00-23:00', '23:00-07:00') NOT NULL,
    -- bool status;
    status BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (shift_id),
    INDEX idx_shift_type (type),
    UNIQUE (day, type)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE nurse_shift (
    AMKA VARCHAR(10) NOT NULL,
    shift_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA, shift_id),
    CONSTRAINT fk_nurse_shift_nurse_id FOREIGN KEY (AMKA) REFERENCES nurse (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_nurse_shift_shift_id FOREIGN KEY (shift_id) REFERENCES shift (shift_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE doctor_shift (
    AMKA VARCHAR(10) NOT NULL,
    shift_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA, shift_id),
    CONSTRAINT fk_doctor_shift_doctor_id FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_doctor_shift_shift_id FOREIGN KEY (shift_id) REFERENCES shift (shift_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE admin_shift (
    AMKA VARCHAR(10) NOT NULL,
    shift_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA, shift_id),
    CONSTRAINT fk_admin_shift_admin_id FOREIGN KEY (AMKA) REFERENCES administrative_staff (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_admin_shift_shift_id FOREIGN KEY (shift_id) REFERENCES shift (shift_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
--  Table structure for insurance carrier 
--

CREATE TABLE insurance_carrier (
    carrier_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY(carrier_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE patient_insurance (
    AMKA VARCHAR(10) NOT NULL,
    carrier_id INT UNSIGNED NOT NULL,
    PRIMARY KEY(AMKA, carrier_id),
    CONSTRAINT fk_patient_insurance_patient_id FOREIGN KEY (AMKA) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_patient_insurance_insurance_id FOREIGN KEY (carrier_id) REFERENCES insurance_carrier (carrier_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
--  Table structure for costing
--

CREATE TABLE costing (
    costing_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    KEN_code VARCHAR(5) NOT NULL,
    description TEXT,
    base_cost NUMERIC(9,2) NOT NULL DEFAULT 000000.00 CHECK (base_cost >= 0),
    mean_hospit_time INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (costing_id),
    UNIQUE (description)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for relation costing ---< covered_by >--> insurance_carrier
--


CREATE TABLE costing_coverage (
    costing_id INT UNSIGNED NOT NULL,
    carrier_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (costing_id),
    INDEX idx_fk_carrier_id (carrier_id),
    CONSTRAINT fk_const_coverage_costing_id FOREIGN KEY (costing_id) REFERENCES costing (costing_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_const_coverage_carrier_id FOREIGN KEY (carrier_id) REFERENCES insurance_carrier (carrier_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
--  Table structure for dianosis
--      based on ICD-10 codes
--

CREATE TABLE diagnosis (
    diag_id VARCHAR(10) NOT NULL,
    description TEXT NOT NULL,
    PRIMARY KEY (diag_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
--  Table structure for hospitalisation
--

CREATE TABLE hospitalisation (
    hosp_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    admission_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    discharge_date TIMESTAMP DEFAULT NULL CHECK (discharge_date = NULL OR discharge_date > admission_date),
    dept_name VARCHAR(45) NOT NULL,
    bed_id INT UNSIGNED NOT NULL,
    costing_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (hosp_id),
    INDEX idx_admission_date (admission_date),
    INDEX idx_fk_dept_name (dept_name),
    CONSTRAINT fk_hosp_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_hosp_bed_id FOREIGN KEY (bed_id) REFERENCES bed (bed_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_hosp_costing_id FOREIGN KEY (costing_id) REFERENCES costing (costing_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for relation hospitalisation ---< has_record >--> patient
--

CREATE TABLE patient_record (
    AMKA VARCHAR(45) NOT NULL,
    hosp_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (hosp_id),
    INDEX idx_fk_patient_id (AMKA),
    CONSTRAINT fk_patient_record_patient_id FOREIGN KEY (AMKA) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_patient_record_hospitalisation_id FOREIGN KEY (hosp_id) REFERENCES hospitalisation (hosp_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
--  Table structures for admission and discharge diagnosis
--

CREATE TABLE admission_diagnosis (
    hosp_id INT UNSIGNED NOT NULL,
    diag_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (hosp_id, diag_id),
    CONSTRAINT fk_adm_diag_hospitalisation_id FOREIGN KEY (hosp_id) REFERENCES hospitalisation (hosp_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_adm_diag_diagnosis_id FOREIGN KEY (diag_id) REFERENCES diagnosis (diag_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE discharge_diagnosis (
    hosp_id INT UNSIGNED NOT NULL,
    diag_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (hosp_id, diag_id),
    CONSTRAINT fk_dis_diag_hospitalisation_id FOREIGN KEY (hosp_id) REFERENCES hospitalisation (hosp_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_dis_diag_diagnosis_id FOREIGN KEY (diag_id) REFERENCES diagnosis (diag_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
--  Table structures for medical procedure 
--

CREATE TABLE medical_procedure (
    med_proc_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    med_proc_code VARCHAR(16) NOT NULL,
    description TEXT NOT NULL,
    PRIMARY KEY (med_proc_id),
    INDEX idx_med_proc_code (med_proc_code),
    UNIQUE (med_proc_code)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
--  Table structures for lab test
--

CREATE TABLE lab_test (
    lab_test_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    med_proc_id INT UNSIGNED NOT NULL,
    doc_id VARCHAR(45) NOT NULL,
    date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    result TEXT NOT NULL,
    cost NUMERIC(8,2) NOT NULL DEFAULT 000000.00 CHECK (cost >= 0),
    PRIMARY KEY (lab_test_id),
    INDEX idx_fk_med_proc_id (med_proc_id),
    INDEX idx_fk_doctor_id (doc_id),
    CONSTRAINT fk_lab_test_med_procedure_id FOREIGN KEY (med_proc_id) REFERENCES medical_procedure (med_proc_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_lab_test_doctor_id FOREIGN KEY (doc_id) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Table structure for relation hospitalisation <--< has >--- lab_test
--

CREATE TABLE hosp_lab_test (
    lab_test_id INT UNSIGNED NOT NULL,
    hosp_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (lab_test_id),
    CONSTRAINT fk_hosp_lab_test_lab_test_id FOREIGN KEY (lab_test_id) REFERENCES lab_test (lab_test_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_hosp_lab_test_hosp_id FOREIGN KEY (hosp_id) REFERENCES hospitalisation (hosp_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for medical act
--

CREATE TABLE medical_act (
    med_act_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type VARCHAR(45) NOT NULL,
    med_proc_id INT UNSIGNED NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    room_id INT UNSIGNED NOT NULL,
    cost NUMERIC(8,2) NOT NULL DEFAULT 000000.00 CHECK (cost >= 0),
    PRIMARY KEY (med_act_id),
    INDEX idx_fk_med_proc_id (med_proc_id),
    INDEX idx_fk_room_id (room_id),
    CHECK (start_datetime < end_datetime),
    CONSTRAINT fk_medical_act_med_procedure_id FOREIGN KEY (med_proc_id) REFERENCES medical_procedure (med_proc_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_medical_act_room_id FOREIGN KEY (room_id) REFERENCES room (room_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for surgical act and staff assistance 
--

CREATE TABLE surgical_act (
    med_act_id INT UNSIGNED NOT NULL,
    primary_doc_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (med_act_id, primary_doc_id),
    CONSTRAINT fk_surgery_med_procedure_id FOREIGN KEY (med_act_id) REFERENCES medical_act (med_act_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_surgery_primary_doc_id FOREIGN KEY (primary_doc_id) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE surgical_act_doctor_assistants (
    med_act_id INT UNSIGNED NOT NULL,
    assistant_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (med_act_id, assistant_id),
    CONSTRAINT fk_surg_doc_surg_act_id FOREIGN KEY (med_act_id) REFERENCES surgical_act (med_act_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_surg_doc_assist_id FOREIGN KEY (assistant_id) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE surgical_act_nurse_assistants (
    med_act_id INT UNSIGNED NOT NULL,
    assistant_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (med_act_id, assistant_id),
    CONSTRAINT fk_surg_nurse_surg_act_id FOREIGN KEY (med_act_id) REFERENCES surgical_act (med_act_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_surg_nurse_assist_id FOREIGN KEY (assistant_id) REFERENCES nurse (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for relation hospitalisation <--< has >--- medical_act 
--

CREATE TABLE hosp_med_act (
    med_act_id INT UNSIGNED NOT NULL,
    hosp_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (med_act_id),
    INDEX idx_fk_hosp_id (hosp_id),
    CONSTRAINT fk_hosp_med_act_med_act_id FOREIGN KEY (med_act_id) REFERENCES medical_act (med_act_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_hosp_med_act_hospit_id FOREIGN KEY (hosp_id) REFERENCES hospitalisation (hosp_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for rating 
--

CREATE TABLE rating (
    AMKA VARCHAR(45) NOT NULL,
    hosp_id INT UNSIGNED NOT NULL,
    medical_care TINYINT(1) UNSIGNED DEFAULT NULL CHECK (1 <= medical_care  AND medical_care <= 5),
    nursing_case TINYINT(1) UNSIGNED DEFAULT NULL CHECK (1 <= nursing_case  AND nursing_case <= 5),
    cleanliness TINYINT(1) UNSIGNED DEFAULT NULL CHECK (1 <= cleanliness  AND cleanliness <= 5),
    food TINYINT(1) UNSIGNED DEFAULT NULL CHECK (1 <= food  AND food <= 5),
    experience TINYINT(1) UNSIGNED DEFAULT NULL CHECK (1 <= experience  AND experience <= 5),
    PRIMARY KEY (AMKA, hosp_id),
    CONSTRAINT fk_rating_patient_id FOREIGN KEY (AMKA) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rating_hosp_id FOREIGN KEY (hosp_id) REFERENCES hospitalisation (hosp_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structures for pharmaceutical products
--

CREATE TABLE active_substance (
    act_sub_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    -- act_sub VARCHAR(100) NOT NULL,
    act_sub_full TEXT NOT NULL UNIQUE,
    PRIMARY KEY (act_sub_id),
    -- INDEX idx_act_sub (act_sub)
    INDEX idx_act_sub (act_sub_full(100))
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE route_of_admission (
    route_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type VARCHAR(255) NOT NULL UNIQUE,
    PRIMARY KEY (route_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE pharmaceutical_product (
    pharm_prod_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    auth_country VARCHAR(100) NOT NULL,
    marketing_auth_holder VARCHAR(255) NOT NULL,
    master_file_loc VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(100) NOT NULL,
    PRIMARY KEY (pharm_prod_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_act_sub (
    act_sub_id INT UNSIGNED NOT NULL,
    pharm_prod_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (act_sub_id, pharm_prod_id),
    CONSTRAINT fk_prod_act_sub_sub_id FOREIGN KEY (act_sub_id) REFERENCES active_substance (act_sub_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prod_act_product_id FOREIGN KEY (pharm_prod_id) REFERENCES pharmaceutical_product (pharm_prod_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE product_route (
    route_id INT UNSIGNED NOT NULL,
    pharm_prod_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (route_id, pharm_prod_id),
    CONSTRAINT fk_prod_route_route_id FOREIGN KEY (route_id) REFERENCES route_of_admission (route_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prod_route_product_id FOREIGN KEY (pharm_prod_id) REFERENCES pharmaceutical_product (pharm_prod_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structures for patient allergies 
--

CREATE TABLE patient_allergy (
    AMKA VARCHAR(10) NOT NULL,
    act_sub_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA, act_sub_id),
    CONSTRAINT fk_allergy_patient_id FOREIGN KEY (AMKA) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_allergy_substance_id FOREIGN KEY (act_sub_id) REFERENCES active_substance (act_sub_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structures for prescription 
--

CREATE TABLE prescription (
    prescription_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    doctor_id VARCHAR(10) NOT NULL,
    patient_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (prescription_id),
    INDEX idx_fk_doctor_id (doctor_id),
    INDEX idx_fk_patient_id (patient_id),
    CONSTRAINT fk_prescription_doctor_id FOREIGN KEY (doctor_id) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prescription_patient_id FOREIGN KEY (patient_id) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE prescribed_products (
    prescription_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    pharm_prod_id INT UNSIGNED NOT NULL,
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE NOT NULL CHECK (end_date >= start_date),
    dosage VARCHAR(255) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    PRIMARY KEY (prescription_id, pharm_prod_id, start_date),
    CONSTRAINT fk_prescr_prod_prescription_id FOREIGN KEY (prescription_id) REFERENCES prescription (prescription_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prescr_prod_product_id FOREIGN KEY (pharm_prod_id) REFERENCES pharmaceutical_product (pharm_prod_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structures for media 
--

CREATE TABLE media (
    media_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    path VARCHAR(255) NOT NULL,
    description TEXT,
    PRIMARY KEY (media_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE doctor_media (
    media_id INT UNSIGNED NOT NULL,
    doctor_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (media_id, doctor_id),
    CONSTRAINT fk_doctor_media_media_id FOREIGN KEY (media_id) REFERENCES media (media_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_doctor_media_entity_id FOREIGN KEY (doctor_id) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE nurse_media (
    media_id INT UNSIGNED NOT NULL,
    nurse_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (media_id, nurse_id),
    CONSTRAINT fk_nurse_media_media_id FOREIGN KEY (media_id) REFERENCES media (media_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_nurse_media_entity_id FOREIGN KEY (nurse_id) REFERENCES nurse (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE admin_media (
    media_id INT UNSIGNED NOT NULL,
    admin_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (media_id, admin_id),
    CONSTRAINT fk_admin_media_media_id FOREIGN KEY (media_id) REFERENCES media (media_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_admin_media_entity_id FOREIGN KEY (admin_id) REFERENCES administrative_staff (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE equipment_media (
    media_id INT UNSIGNED NOT NULL,
    equipment_id VARCHAR(128) NOT NULL,
    PRIMARY KEY (media_id, equipment_id),
    CONSTRAINT fk_equipment_media_media_id FOREIGN KEY (media_id) REFERENCES media (media_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_equipment_media_entity_id FOREIGN KEY (equipment_id) REFERENCES equipment (UID) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bed_media (
    media_id INT UNSIGNED NOT NULL,
    bed_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (media_id, bed_id),
    CONSTRAINT fk_bed_media_media_id FOREIGN KEY (media_id) REFERENCES media (media_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bed_media_entity_id FOREIGN KEY (bed_id) REFERENCES bed (bed_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE room_media (
    media_id INT UNSIGNED NOT NULL,
    room_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (media_id, room_id),
    CONSTRAINT fk_room_media_media_id FOREIGN KEY (media_id) REFERENCES media (media_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_room_media_entity_id FOREIGN KEY (room_id) REFERENCES room (room_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;








-- ==============================================================================
--                                   Triggers
-- ==============================================================================

DELIMITER ;;

-- =========================================================== 
--                     Doctor Supervison
-- =========================================================== 

CREATE TRIGGER ins_doc_supervisor_cycle BEFORE INSERT ON doctor FOR EACH ROW BEGIN
    IF NEW.supervisor_id IS NOT NULL THEN

        SET @supervisee_id = NEW.AMKA;
        SET @supervisor_id = NEW.supervisor_id;
        SET @cycle_detection = 0;

        WITH RECURSIVE supervision_cycle AS (
            SELECT AMKA, supervisor_id
            FROM doctor
            WHERE AMKA = @supervisee_id
            UNION ALL
            SELECT doc.AMKA, doc.supervisor_id
            FROM doctor doc
            JOIN supervision_cycle hlpr ON doc.AMKA = hlpr.supervisor_id
        )
        SELECT COUNT(*) INTO @cycle_detection
        FROM supervision_cycle
        WHERE AMKA = @supervisor_id;

        IF @cycle_detection > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cyclic doctor supervision is not permitted';
        END IF;
    END IF;
END;;

CREATE TRIGGER upd_doc_supervisor_cycle BEFORE UPDATE ON doctor FOR EACH ROW BEGIN
    IF NEW.supervisor_id IS NOT NULL THEN

        SET @supervisee_id = NEW.AMKA;
        SET @supervisor_id = NEW.supervisor_id;
        SET @cycle_detection = 0;

        WITH RECURSIVE supervision_cycle AS (
            SELECT AMKA, supervisor_id
            FROM doctor
            WHERE AMKA = @supervisee_id
            UNION ALL
            SELECT doc.AMKA, doc.supervisor_id
            FROM doctor doc
            JOIN supervision_cycle hlpr ON doc.AMKA = hlpr.supervisor_id
        )
        SELECT COUNT(*) INTO @cycle_detection
        FROM supervision_cycle
        WHERE AMKA = @supervisor_id;

        IF @cycle_detection > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cyclic doctor supervision is not permitted';
        END IF;
    END IF;
END;;

--
-- Junior doctors must have a supervisor
-- Director cannot have a supervisor
--

CREATE TRIGGER ins_doc_supervisor BEFORE INSERT ON doctor FOR EACH ROW BEGIN
    DECLARE rank_t VARCHAR(45);

    IF NEW.rank = 'Διευθυντής' AND NEW.supervisor_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Director cannot have a supervisor';
    END IF;

    IF NEW.rank = 'Ειδικευόμενος' AND NEW.supervisor_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Junior doctors must have a supervisor';
    END IF;

    IF NEW.supervisor_id IS NOT NULL THEN
        SELECT rank INTO rank_t
        FROM doctor
        WHERE AMKA = NEW.supervisor_id;

        IF rank_t = 'Ειδικευόμενος' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Junior doctors may not be supervisors';
        END IF;
    END IF;
END;;


CREATE TRIGGER upd_doc_supervisor BEFORE UPDATE ON doctor FOR EACH ROW BEGIN
    DECLARE rank_t VARCHAR(45);

    IF NEW.rank = 'Διευθυντής' AND NEW.supervisor_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Director cannot have a supervisor';
    END IF;

    IF NEW.rank = 'Ειδικευόμενος' AND NEW.supervisor_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Junior doctors must have a supervisor';
    END IF;

    IF NEW.supervisor_id IS NOT NULL THEN
        SELECT rank INTO rank_t
        FROM doctor
        WHERE AMKA = NEW.supervisor_id;

        IF rank_t = 'Ειδικευόμενος' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Junior doctors may not be supervisors';
        END IF;
    END IF;
END;;
-- =========================================================== 
--                      Hospitalisation 
-- =========================================================== 

CREATE TRIGGER upd_hospitalisation_discharge_date BEFORE UPDATE ON hospitalisation FOR EACH ROW BEGIN
    IF NEW.discharge_date IS NOT NULL 
        AND NEW.admission_date > NEW.discharge_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Admission date must precede discharge date';
    END IF;
END;;



--
-- Shift verification triggers
-- A shift may have status = 1 if and only if it has
--          >= 3 doctors     AND
--          >= 6 nurses      AND
--          >= 2 admin staff
-- AND if a junior doctor is part of a shift, 
--     then at least one senior doctor must be present

CREATE TRIGGER upd_shift_validity BEFORE UPDATE ON shift FOR EACH ROW BEGIN
    DECLARE d_cnt INT DEFAULT 0;
    DECLARE n_cnt INT DEFAULT 0;
    DECLARE a_cnt INT DEFAULT 0;
    DECLARE jr_cnt INT DEFAULT 0;
    DECLARE sr_cnt INT DEFAULT 0;

    IF NEW.status = TRUE THEN 
        SELECT COUNT(*) INTO d_cnt
        FROM doctor_shift WHERE shift_id = NEW.shift_id;

        SELECT COUNT(*) INTO n_cnt
        FROM nurse_shift  WHERE shift_id = NEW.shift_id;

        SELECT COUNT(*) INTO a_cnt
        FROM admin_shift  WHERE shift_id = NEW.shift_id;

        IF (d_cnt < 3) OR (n_cnt < 6) OR (a_cnt < 2) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shift does not meet minimum staffing requirements';
        END IF;

        SELECT COUNT(*) INTO jr_cnt
        FROM doctor_shift ds
        INNER JOIN doctor d ON ds.AMKA = d.AMKA
        WHERE ds.shift_id = NEW.shift_id
          AND d.rank = 'Ειδικευόμενος';
        
        SELECT COUNT(*) INTO sr_cnt
        FROM doctor_shift ds
        INNER JOIN doctor d ON ds.AMKA = d.AMKA
        WHERE ds.shift_id = NEW.shift_id
          AND d.rank IN ('Επιμελητής Α', 'Διευθυντής');

        IF jr_cnt > 0 AND sr_cnt = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Shift with junior doctor should have at least one senior doctor assigned';
        END IF;

    END IF;
END;;

CREATE TRIGGER del_doctor_shift BEFORE DELETE ON doctor_shift FOR EACH ROW BEGIN
    DECLARE cnt INT DEFAULT 0;
    DECLARE jr_cnt INT DEFAULT 0;
    DECLARE sr_cnt INT DEFAULT 0;

    SELECT COUNT(*) INTO cnt
    from doctor_shift WHERE shift_id = OLD.shift_id;

    if cnt < 3 THEN
        UPDATE shift
        SET status = FALSE 
        WHERE shift_id = OLD.shift_id;
    END IF;

    SELECT COUNT(*) INTO jr_cnt
    FROM doctor_shift ds
    INNER JOIN doctor d ON ds.AMKA = d.AMKA
    WHERE ds.shift_id = OLD.shift_id
        AND d.rank = 'Ειδικευόμενος';
    
    SELECT COUNT(*) INTO sr_cnt
    FROM doctor_shift ds
    INNER JOIN doctor d ON ds.AMKA = d.AMKA
    WHERE ds.shift_id = OLD.shift_id
        AND d.rank IN ('Επιμελητής Α', 'Διευθυντής');

    IF jr_cnt > 0 AND sr_cnt = 0 THEN
        UPDATE shift
        SET status = FALSE 
        WHERE shift_id = OLD.shift_id;
    END IF;
END;;

CREATE TRIGGER del_nurse_shift BEFORE DELETE ON nurse_shift FOR EACH ROW BEGIN
    DECLARE cnt INT DEFAULT 0;

    SELECT COUNT(*) INTO cnt
    from nurse_shift WHERE shift_id = OLD.shift_id;

    if cnt < 6 THEN
        UPDATE shift
        SET status = FALSE 
        WHERE shift_id = OLD.shift_id;
    END IF;
END;;

CREATE TRIGGER del_admin_shift BEFORE DELETE ON admin_shift FOR EACH ROW BEGIN
    DECLARE cnt INT DEFAULT 0;

    SELECT COUNT(*) INTO cnt
    from admin_shift WHERE shift_id = OLD.shift_id;

    if cnt < 2 THEN
        UPDATE shift
        SET status = FALSE 
        WHERE shift_id = OLD.shift_id;
    END IF;
END;;

--
-- Additional restrictions
-- ~ no staff member may have 2 consecutive shifts
-- ~ no staff member may have > 3 consecutive night shifts
--

CREATE TRIGGER ins_consecutive_doctor_shift BEFORE INSERT ON doctor_shift FOR EACH ROW BEGIN
    DECLARE day_t DATE;
    DECLARE type_t INT;
    DECLARE cnt INT DEFAULT 0;

    SELECT day, type+0 INTO day_t, type_t
    FROM shift
    WHERE shift_id = NEW.shift_id; 

    IF type_t = 3 THEN

        SELECT COUNT(*) INTO cnt
        FROM shift s
        INNER JOIN doctor_shift ds ON ds.shift_id = s.shift_id
        WHERE ds.AMKA = NEW.AMKA
          AND s.day >= DATE_SUB(day_t, INTERVAL 3 DAY)
          AND s.type+0 = 3;

        IF cnt >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Staff member cannot be assigned to > 3 consecutive shifts';
        END IF;
    END IF;

    IF EXISTS (
        SELECT *
        FROM doctor_shift ds
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE ds.AMKA = NEW.AMKA
          AND (
                ( -- same day: previous of next shift exist
                    s.day = day_t
                    AND (s.type+0 = type_t - 1 OR s.type+0 = type_t + 1)
                )
            OR
                ( -- previous night and current morning
                    s.day = DATE_SUB(day_t, INTERVAL 1 DAY)
                    AND s.type+0 = 3
                    AND type_t = 1
                )
            OR
                ( -- current night and next morning
                    s.day = DATE_ADD(day_t, INTERVAL 1 DAY)
                    AND s.type = 1
                    AND type_t = 3
                )
            )
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Staff member cannot be assigned to consecutive shifts';
    END IF;
END;;

CREATE TRIGGER ins_consecutive_nurse_shift BEFORE INSERT ON nurse_shift FOR EACH ROW BEGIN
    DECLARE day_t DATE;
    DECLARE type_t INT;
    DECLARE cnt INT DEFAULT 0;

    SELECT day, type+0 INTO day_t, type_t
    FROM shift
    WHERE shift_id = NEW.shift_id; 

    IF type_t = 3 THEN

        SELECT COUNT(*) INTO cnt
        FROM shift s
        INNER JOIN nurse_shift ds ON ds.shift_id = s.shift_id
        WHERE ds.AMKA = NEW.AMKA
          AND s.day >= DATE_SUB(day_t, INTERVAL 3 DAY)
          AND s.type+0 = 3;

        IF cnt >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Staff member cannot be assigned to > 3 consecutive shifts';
        END IF;
    END IF;

    IF EXISTS (
        SELECT *
        FROM nurse_shift ds
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE ds.AMKA = NEW.AMKA
          AND (
                ( -- same day: previous of next shift exist
                    s.day = day_t
                    AND (s.type+0 = type_t - 1 OR s.type+0 = type_t + 1)
                )
            OR
                ( -- previous night and current morning
                    s.day = DATE_SUB(day_t, INTERVAL 1 DAY)
                    AND s.type+0 = 3
                    AND type_t = 1
                )
            OR
                ( -- current night and next morning
                    s.day = DATE_ADD(day_t, INTERVAL 1 DAY)
                    AND s.type = 1
                    AND type_t = 3
                )
            )
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Staff member cannot be assigned to consecutive shifts';
    END IF;
END;;

CREATE TRIGGER ins_consecutive_admin_shift BEFORE INSERT ON admin_shift FOR EACH ROW BEGIN
    DECLARE day_t DATE;
    DECLARE type_t INT;
    DECLARE cnt INT DEFAULT 0;

    SELECT day, type+0 INTO day_t, type_t
    FROM shift
    WHERE shift_id = NEW.shift_id; 

    IF type_t = 3 THEN

        SELECT COUNT(*) INTO cnt
        FROM shift s
        INNER JOIN admin_shift ds ON ds.shift_id = s.shift_id
        WHERE ds.AMKA = NEW.AMKA
          AND s.day >= DATE_SUB(day_t, INTERVAL 3 DAY)
          AND s.type+0 = 3;

        IF cnt >= 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Staff member cannot be assigned to > 3 consecutive shifts';
        END IF;
    END IF;

    IF EXISTS (
        SELECT *
        FROM admin_shift ds
        INNER JOIN shift s ON ds.shift_id = s.shift_id
        WHERE ds.AMKA = NEW.AMKA
          AND (
                ( -- same day: previous of next shift exist
                    s.day = day_t
                    AND (s.type+0 = type_t - 1 OR s.type+0 = type_t + 1)
                )
            OR
                ( -- previous night and current morning
                    s.day = DATE_SUB(day_t, INTERVAL 1 DAY)
                    AND s.type+0 = 3
                    AND type_t = 1
                )
            OR
                ( -- current night and next morning
                    s.day = DATE_ADD(day_t, INTERVAL 1 DAY)
                    AND s.type = 1
                    AND type_t = 3
                )
            )
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Staff member cannot be assigned to consecutive shifts';
    END IF;
END;;

--
-- Monthly shift amount limit 
-- ~ doctors: 15
-- ~ nurses: 20
-- ~ admin: 25
--

CREATE TRIGGER ins_doctor_monthly_shift_lim BEFORE INSERT ON doctor_shift FOR EACH ROW BEGIN
    DECLARE date_t DATE;
    DECLARE cnt INT DEFAULT 0;

    SELECT day INTO date_t
    FROM shift
    WHERE shift_id = NEW.shift_id;

    SELECT COUNT(*) INTO cnt
    FROM doctor_shift ds
    INNER JOIN shift s ON ds.shift_id = s.shift_id
    WHERE ds.AMKA = NEW.AMKA
      AND YEAR(s.day) = YEAR(date_t)
      AND MONTH(s.day) = MONTH(date_t);

    IF cnt >= 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctors may be assigned to a maximum of 15 shifts per month';
    END IF;
END;;

CREATE TRIGGER ins_nurse_monthly_shift_lim BEFORE INSERT ON nurse_shift FOR EACH ROW BEGIN
    DECLARE date_t DATE;
    DECLARE cnt INT DEFAULT 0;

    SELECT day INTO date_t
    FROM shift
    WHERE shift_id = NEW.shift_id;

    SELECT COUNT(*) INTO cnt
    FROM nurse_shift ds
    INNER JOIN shift s ON ds.shift_id = s.shift_id
    WHERE ds.AMKA = NEW.AMKA
      AND YEAR(s.day) = YEAR(date_t)
      AND MONTH(s.day) = MONTH(date_t);

    IF cnt >= 20 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nurses may be assigned to a maximum of 20 shifts per month';
    END IF;
END;;

CREATE TRIGGER ins_admin_monthly_shift_lim BEFORE INSERT ON admin_shift FOR EACH ROW BEGIN
    DECLARE date_t DATE;
    DECLARE cnt INT DEFAULT 0;

    SELECT day INTO date_t
    FROM shift
    WHERE shift_id = NEW.shift_id;

    SELECT COUNT(*) INTO cnt
    FROM admin_shift ds
    INNER JOIN shift s ON ds.shift_id = s.shift_id
    WHERE ds.AMKA = NEW.AMKA
      AND YEAR(s.day) = YEAR(date_t)
      AND MONTH(s.day) = MONTH(date_t);

    IF cnt >= 25 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'administrative staff may be assigned to a maximum of 25 shifts per month';
    END IF;
END;;


-- =========================================================== 
--                        Prescriptions 
-- =========================================================== 

CREATE TRIGGER ins_prescribed_prod_patient_allergy BEFORE INSERT ON prescribed_products FOR EACH ROW BEGIN
    DECLARE patient_id_t VARCHAR(10);
    DECLARE act_sub_id_t INT UNSIGNED;

    SELECT patient_id INTO patient_id_t
    FROM prescription
    WHERE prescription_id = NEW.prescription_id;

    IF EXISTS (
        SELECT *
        FROM product_act_sub pas
        INNER JOIN patient_allery pa ON pas.act_sub_id = pa.act_sub_id
        WHERE pa.AMKA = patient_id 
          AND pas.act_sub_id IN (SELECT act_sub_id 
                                 FROM product_act_sub 
                                 WHERE pharm_prod_id = NEW.pharm_prod_id)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Patient allergic to prescribed active substance';
    END IF;
END;;



CREATE TRIGGER upd_prescribed_prod_patient_allergy BEFORE UPDATE ON prescribed_products FOR EACH ROW BEGIN
    DECLARE patient_id_t VARCHAR(10);

    SELECT patient_id INTO patient_id_t
    FROM prescription
    WHERE prescription_id = NEW.prescription_id;

    IF EXISTS (
        SELECT *
        FROM product_act_sub pas
        INNER JOIN patient_allery pa ON pas.act_sub_id = pa.act_sub_id
        WHERE pa.AMKA = patient_id 
          AND pas.act_sub_id IN (SELECT act_sub_id 
                                 FROM product_act_sub 
                                 WHERE pharm_prod_id = NEW.pharm_prod_id)

    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Patient allergic to prescribed active substance';
    END IF;
END;;

-- =========================================================== 
--                          Surgery
-- =========================================================== 

-- 
-- Prevent two acts from taking place at the same place at the same time
--

CREATE TRIGGER ins_surgery_locality_overlap BEFORE INSERT ON surgical_act FOR EACH ROW BEGIN
    DECLARE start_t DATETIME;
    DECLARE end_t TIME;
    DECLARE room_t INT UNSIGNED;

    SELECT start_datetime, end_datetime, room_id INTO start_t, end_t, room_t
    FROM medical_act
    WHERE med_act_id = NEW.med_act_id;

    IF EXISTS (
        SELECT *
        FROM surgical_act sa
        INNER JOIN medical_act ma ON ma.med_act_id = sa.med_act_id
        WHERE ma.room_id = room_t 
        AND (ma.end_datetime > start_t AND ma.start_datetime < end_t)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room in use';
    END IF;
END;;

-- 
-- Prevent temporal overlaps when assigning staff
--

CREATE TRIGGER ins_surgery_temporality_main_doc BEFORE INSERT ON surgical_act FOR EACH ROW BEGIN
    DECLARE start_t DATETIME;
    DECLARE end_t TIME;

    SELECT start_datetime, end_datetime INTO start_t, end_t
    FROM medical_act
    WHERE med_act_id = NEW.med_act_id;

    IF EXISTS (
        SELECT *
        FROM surgical_act sa
        INNER JOIN medical_act ma ON ma.med_act_id = sa.med_act_id
        WHERE sa.primary_doc_id = NEW.primary_doc_id
        AND (ma.end_datetime > start_t AND ma.start_datetime < end_t)
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Primary doctor already assigned at given time';
    END IF;
END;;

CREATE TRIGGER ins_surgery_temporality_assist_doc BEFORE INSERT ON surgical_act_doctor_assistants FOR EACH ROW BEGIN
    DECLARE start_t DATETIME;
    DECLARE end_t TIME;
    DECLARE primary_doc_t VARCHAR(10);

    SELECT start_datetime, end_datetime INTO start_t, end_t
    FROM medical_act
    WHERE med_act_id = NEW.med_act_id;

    IF EXISTS (
        SELECT *
        FROM surgical_act_doctor_assistants sa
        INNER JOIN medical_act ma1 ON ma1.med_act_id = sa.med_act_id
        WHERE sa.assistant_id = NEW.assistant_id
        AND (ma.end_datetime > start_t AND ma.start_datetime < end_t)
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Assistant doctor already assigned at given time';
    END IF;


    -- Prevent insertion if doctor is already primary doctor of act
    SELECT primary_doc_id INTO primary_doc_t
    FROM surgical_act
    WHERE med_act_id = NEW.med_act_id;

    IF primary_doc_t = NEW.assistant_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Assistant doctor already assigned as primary doctor';
    END IF;
END;;

CREATE TRIGGER ins_surgery_temporality_assist_nurse BEFORE INSERT ON surgical_act_nurse_assistants FOR EACH ROW BEGIN
    DECLARE start_t DATETIME;
    DECLARE end_t TIME;

    SELECT start_datetime, end_datetime INTO start_t, end_t
    FROM medical_act
    WHERE med_act_id = NEW.med_act_id;

    IF EXISTS (
        SELECT *
        FROM surgical_act_nurse_assistants sa
        INNER JOIN medical_act ma1 ON ma1.med_act_id = sa.med_act_id
        WHERE sa.assistant_id = NEW.assistant_id
        AND (ma.end_datetime > start_t AND ma.start_datetime < end_t)
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Assistant nurse doctor already assigned at given time';
    END IF;
END;;

/*
*/

-- =========================================================== 
--                          Rating 
-- =========================================================== 
-- A rating can only be given after a hospitalisation has ended

CREATE TRIGGER ins_rating BEFORE INSERT ON rating FOR EACH ROW BEGIN
    DECLARE discharge_t TIMESTAMP; 

    SELECT discharge_date INTO discharge_t
    FROM hospitalisation
    WHERE hosp_id = NEW.hosp_id;

    IF discharge_t IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hospitalisation in progress; cannot assign rating';
    END IF;
END;;

-- =========================================================== 
--                     Medical/test procedures 
-- =========================================================== 
-- A rating can only be given after a hospitalisation has ended

CREATE TRIGGER ins_lab_test BEFORE INSERT ON lab_test FOR EACH ROW BEGIN
    IF NEW.med_proc_id <= 6608 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lab test are described by sections Γ, Δ, Ε of the Greek medical procedure encoding standard';
    END IF;
END;;

CREATE TRIGGER upd_lab_test BEFORE UPDATE ON lab_test FOR EACH ROW BEGIN
    IF NEW.med_proc_id <= 6608 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lab test are described by sections Γ, Δ, Ε of the Greek medical procedure encoding standard';
    END IF;
END;;

CREATE TRIGGER ins_medical_act BEFORE INSERT ON medical_act FOR EACH ROW BEGIN
    IF NEW.med_proc_id > 6608 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medical acts are described by sections Α, Β of the Greek medical procedure encoding standard';
    END IF;
END;;

CREATE TRIGGER upd_medical_act BEFORE UPDATE ON medical_act FOR EACH ROW BEGIN
    IF NEW.med_proc_id > 6608 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medical acts are described by sections Α, Β of the Greek medical procedure encoding standard';
    END IF;
END;;

DELIMITER ;

-- ==============================================================================
--                                    Views 
-- ==============================================================================

--
-- Triage: patients treated based on emergency level + FIFO
--
CREATE VIEW triage_queue AS
SELECT *
FROM triage
ORDER BY level DESC, arrival_time ASC;

--
-- Print doctor specialisation along with values of doctor table
--
CREATE VIEW doctor_info AS
SELECT d.AMKA, d.first_name, d.last_name, d.middle_name, d.date_of_birth, d.date_of_employment, d.license_number, d.supervisor_id, s.description_grc
FROM doctor d
INNER JOIN doc_spec ds ON d.AMKA = ds.AMKA
INNER JOIN specialisation s ON ds.spec_code = s.spec_code;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
