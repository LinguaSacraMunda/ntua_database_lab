/*
SQL script για τη δημιουργία του σχήματος της βάσης δεδομένων
*/

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP SCHEMA IF EXISTS ntua_db_2026;
CREATE SCHEMA ntua_db_2026;
USE ntua_db_2026;



--
-- Table structure for patient
--

CREATE TABLE patient (
    AMKA INT UNSIGNED NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    date_of_birth DATE NOT NULL,
    sex  ENUM('male', 'female', 'other') NOT NULL,
    weight NUMERIC(5,2) NOT NULL DEFAULT 000.00,   --in kg
    height NUMERIC(5,2) NOT NULL DEFAULT 000.00,   --in cm
    --address
    street_name VARCHAR(45) DEFAULT NULL,
    street_number VARCHAR(45) DEFAULT NULL,
    postal_code VARCHAR(10) DEFAULT NULL,
    area VARCHAR(45) DEFAULT NULL,
    municipality VARCHAR(45) DEFAULT NULL,
    prefecture VARCHAR(45) DEFAULT NULL,
    --address end
    proffesion VARCHAR(45) DEFAULT NULL,
    citizenship VARCHAR(45) DEFAULT NULL,

    triage_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (AMKA),
    --CONSTRAINT fk_patient_triage FOREIGN KEY (triage_id) REFERENCES triage (triage_id) ON DELETE RESTRICT ON UPFATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE patient_email (
    AMKA INT UNSIGNED NOT NULL,
    email_address VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, email_address),
    CONSTRAINT fk_patient_email FOREIGN KEY (AMKA) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE patient_phone (
    AMKA INT UNSIGNED NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (AMKA, phone_number),
    CONSTRAINT fk_patient_phone FOREIGN KEY (AMKA) REFERENCES patient (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for nurse 
--

CREATE TABLE nurse (
    AMKA INT UNSIGNED NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_employment DATE NOT NULL,
    rank ENUM('Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος') NOT NULL,
    dept_name INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA),
    CONSTRAINT fk_nurse_dept FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE nurse_email (
    AMKA INT UNSIGNED NOT NULL,
    email_address VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, email_address),
    CONSTRAINT fk_nurse_email FOREIGN KEY (AMKA) REFERENCES nurse (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE nurse_phone (
    AMKA INT UNSIGNED NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (AMKA, phone_number),
    CONSTRAINT fk_nurse_phone FOREIGN KEY (AMKA) REFERENCES nurse (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for administrative staff 
--

CREATE TABLE administrative_staff (
    AMKA INT UNSIGNED NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_employment DATE NOT NULL,
    role ENUM('Γραμματεία', 'Λογιστήριο', 'Ανθρώπινο Δυναμικό', 'Τεχνική Υποστήριξη') NOT NULL,
    office VARCHAR(10) NOT NULL,
    dept_name INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA),
    CONSTRAINT fk_admin_dept FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE admin_email (
    AMKA INT UNSIGNED NOT NULL,
    email_address VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, email_address),
    CONSTRAINT fk_admin_email FOREIGN KEY (AMKA) REFERENCES administrative_staff (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE admin_phone (
    AMKA INT UNSIGNED NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (AMKA, phone_number),
    CONSTRAINT fk_admin_phone FOREIGN KEY (AMKA) REFERENCES administrative_staff (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Table structure for doctor 
--

CREATE TABLE doctor (
    AMKA INT UNSIGNED NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    middle_name VARCHAR(45) DEFAULT NULL,
    last_name VARCHAR(45) NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_employment DATE NOT NULL,
    license_number VARCHAR(20) NOT NULL,
    rank ENUM('Ειδικευόμενος', 'Επιμελητής Β', 'Επιμελητής Α', 'Διευθυντής') NOT NULL,
    supervisor_id INT UNSIGNED DEFAULT NULL,
    PRIMARY KEY (AMKA),
    CONSTRAINT fk_supervisor_id FOREIGN KEY (supervisor_id) REFERENCES doctor (AMKA) ON DELETE SET NULL ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE doctor_email (
    AMKA INT UNSIGNED NOT NULL,
    email_address VARCHAR(45) NOT NULL,
    PRIMARY KEY (AMKA, email_address),
    CONSTRAINT fk_doctor_email FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE doctor_phone (
    AMKA INT UNSIGNED NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (AMKA, phone_number),
    CONSTRAINT fk_doctor_phone FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Doctor specialisation
--

CREATE TABLE specialisation (
    spec_code VARCHAR(5) NOT NULL,
    description VARCHAR(45) NOT NULL,
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE doc_spec (
    AMKA INT UNSIGNED NOT NULL,
    spec_code VARCHAR(5) NOT NULL,
    PRIMARY KEY (AMKA, spec_code),
    CONSTRAINT fk_doctor_id FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_spec_id FOREIGN KEY (spec_code) REFERENCES specialisation (spec_code) ON DELETE RESTRICT ON UPDATE CASCADE,
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Triggers to prevent circular doctor supervision
--
DELIMITER ;;
CREATE TRIGGER ins_doc_supervisor BEFORE INSERT ON doctor FOR EACH ROW BEGIN
    IF NEW.supervisor_id IS NULL THEN
        LEAVE;
    END IF;

    SET @supervisee_id = NEW.AMKA;
    SET @supervisor_id = NEW.supervisor_id;
    SET @cycle_detection = 0;

    RECURSIVE supervision_cycle AS (
        SELECT AMKA, supervisor_id
        FROM doctor
        WHERE AMKA = @supervisee_id
        UNION ALL
        SELECT doc.AMKA, doc.supervisor_id
        FROM doctor doc
        JOIN supervision_cycle hlpr ON doc.AMKA = hlpr.supervision_cycle
    )
    SELECT COUNT(*) INTO @cycle_detection
    FROM supervision_cycle
    WHERE AMKA = @supervisor_id

    IF @cycle_detection > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cyclic doctor supervision is not permitted';
    END IF
END;;

CREATE TRIGGER upd_doc_supervisor BEFORE UPDATE ON doctor FOR EACH ROW BEGIN
    IF NEW.supervisor_id IS NULL THEN
        LEAVE;
    END IF;

    SET @supervisee_id = NEW.AMKA;
    SET @supervisor_id = NEW.supervisor_id;
    SET @cycle_detection = 0;

    RECURSIVE supervision_cycle AS (
        SELECT AMKA, supervisor_id
        FROM doctor
        WHERE AMKA = @supervisee_id
        UNION ALL
        SELECT doc.AMKA, doc.supervisor_id
        FROM doctor doc
        JOIN supervision_cycle hlpr ON doc.AMKA = hlpr.supervision_cycle
    )
    SELECT COUNT(*) INTO @cycle_detection
    FROM supervision_cycle
    WHERE AMKA = @supervisor_id

    IF @cycle_detection > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cyclic doctor supervision is not permitted';
    END IF
END;;
DELIMITER ;

--
-- Table structure for department
--

CREATE TABLE department (
    dept_name VARCHAR(45) NOT NULL,
    description TEXT NOT NULL,
    number_of_beds INT UNSIGNED NOT NULL DEFAULT = 0,
    floor VARCHAR(5) NOT NULL,
    building VARCHAR(10) NOT NULL,
    director_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (dept_name),
    CONSTRAINT fk_dept_head FOREIGN KEY (director_id) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for doctor-department relation
--

CREATE TABLE doctor_dept (
    AMKA INT UNSIGNED NOT NULL,
    dept_name INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA, dept_name),
    CONSTRAINT fk_doc_dept_doctor_id FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_doc_dept_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
    CONSTRAINT fk_bed_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bed_room_id FOREIGN KEY (room_id) REFERENCES room (room_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for room
--

CREATE TABLE room (
    rood_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type ENUM('Κλίνες', 'Χειρουργική Αίθουσα', 'ΤΕΠ', 'Διαγνωστική Αίθουσα', 'Αίθουσα Αναμονής', 'Γραφείο', 'Αποθήκη') NOT NULL,
    status ENUM('Διαθέσιμη', 'Κατειλημμένη', 'Υπό Συντήρηση') NOT NULL,
    dept_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (rood_id),
    CONSTRAINT fk_room_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for equipment
--

CREATE TABLE equipment (
    UID VARCHAR(128) NOT NULL,
    description TEXT NOT NULL,
    PRIMARY KEY (UID)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE equipment_room (
    UID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    rood_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (UID),
    CONSTRAINT fk_equip_room_UID FOREIGN KEY (UID) REFERENCES equipment (UID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_equip_room_room_id FOREIGN KEY (room_id) REFERENCES room (room_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE equipment_dept (
    UID INT UNSIGNED NOT NULL AUTO_INCREMENT,
    dept_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (UID),
    CONSTRAINT fk_equip_room_UID FOREIGN KEY (UID) REFERENCES equipment (UID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_equip_room_dept_id FOREIGN KEY (dept_name) REFERENCES department (dept_name) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for shift 
--

CREATE TABLE shift (
    shift_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    day DATE NOT NULL,
    type  ENUM('07:00-15:00', '15:00-23:00', '23:00-07:00') NOT NULL,
    -- bool status;
    status TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (shift_id, day, type)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE nurse_shift (
    AMKA INT UNSIGNED NOT NULL,
    shift_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA, shift_id),
    CONSTRAINT fk_nurse_shift_nurse_id FOREIGN KEY (AMKA) REFERENCES nurse (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_nurse_shift_shift_id FOREIGN KEY (shift_id) REFERENCES shift (shift_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE doctor_shift (
    AMKA INT UNSIGNED NOT NULL,
    shift_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA, shift_id),
    CONSTRAINT fk_doctor_shift_doctor_id FOREIGN KEY (AMKA) REFERENCES doctor (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_doctor_shift_shift_id FOREIGN KEY (shift_id) REFERENCES shift (shift_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE admin_shift (
    AMKA INT UNSIGNED NOT NULL,
    shift_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (AMKA, shift_id),
    CONSTRAINT fk_admin_shift_admin_id FOREIGN KEY (AMKA) REFERENCES administrative_staff (AMKA) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_admin_shift_shift_id FOREIGN KEY (shift_id) REFERENCES shift (shift_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
-- Shift verification triggers
-- A shift may have status = 1 if and only if it has
--          >= 3 doctors     AND
--          >= 6 nurses      AND
--          >= 2 admin staff
--

DELIMITER ;;
CREATE TRIGGER upd_shift_validity BEFORE UPDATE ON shift FOR EACH ROW BEGIN
    DECLARE d_cnt INT DEFAULT 0;
    DECLARE n_cnt INT DEFAULT 0;
    DECLARE a_cnt INT DEFAULT 0;

    IF NEW.status = 1 ΤΗΕΝ 
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
    END IF;
END;;

CREATE TRIGGER del_doctor_shift BEFORE DELETE ON doctor_shift FOR EACH ROW BEGIN
    DECLARE cnt INT DEFAULT 0;

    SELECT COUNT(*) INTO cnt
    from doctor_shift WHERE shift_id = OLD.shift_id;

    if cnt < 3 THEN
        UPDATE shift
        SET status = 0
        WHERE shift_if = OLD.shift_if;
    END IF;
END;;

CREATE TRIGGER del_nurse_shift BEFORE DELETE ON nurse_shift FOR EACH ROW BEGIN
    DECLARE cnt INT DEFAULT 0;

    SELECT COUNT(*) INTO cnt
    from nurse_shift WHERE shift_id = OLD.shift_id;

    if cnt < 6 THEN
        UPDATE shift
        SET status = 0
        WHERE shift_if = OLD.shift_if;
    END IF;
END;;

CREATE TRIGGER del_admin_shift BEFORE DELETE ON admin_shift FOR EACH ROW BEGIN
    DECLARE cnt INT DEFAULT 0;

    SELECT COUNT(*) INTO cnt
    from admin_shift WHERE shift_id = OLD.shift_id;

    if cnt < 2 THEN
        UPDATE shift
        SET status = 0
        WHERE shift_if = OLD.shift_if;
    END IF;
END;;

--
-- Additional restrictions
-- ~ no staff member may have > 2 consecutive shifts
-- ~ no staff member may have > 3 consecutive night shifts
--

CREATE TRIGGER ins_doc_shift BEFORE INSERT ON doctor_shift FOR EACH ROW BEGIN
    SELECT * FROM (
        SELECT * FROM shift AS s 
        WHERE s.AMKA = NEW.AMKA
    ) AS hlpr WHERE DATE_SUB(NEW.)
END;;


DELIMITER ;

CREATE TABLE tablename (
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
