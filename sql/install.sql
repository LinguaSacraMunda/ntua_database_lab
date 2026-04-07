/*
SQL script για τη δημιουργία του σχήματος της βάσης δεδομένων
*/

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

drop schema if exists ntua_db_2026;
create schema ntua_db_2026;
use ntua_db_2026;

create table tablename (
)engine=InnoDB default charset=utf8;


--
-- Table structure for patient
--
create table patient (
    AMKA int unsigned not null,
    first_name varchar(45) not null,
    middle_name varchar(45) not null,
    last_name varchar(45) not null,
    date_of_birth date not null,
    sex  enum('male', 'female', 'other') not null,
    weight numeric(5,2) not null default 000.00,   --in kg
    height numeric(5,2) not null default 000.00,   --in cm
    --address
    street_name varchar(45) default null,
    street_number varchar(45) default null,
    postal_code varchar(10) default null,
    area varchar(45) default null,
    municipality varchar(45) default null,
    prefecture varchar(45) default null,
    --address end
    proffesion varchar(45) default null,
    citizenship varchar(45) default null,

    triage_id int unsigned not null auto_increment,
    primary key (AMKA),
    constraint fk_patient_triage foreign key (triage_id) references triage (triage_id) on delete restrict on upfate cascade
)engine=InnoDB default charset=utf8;

create table patient_email (
    AMKA int unsigned not null,
    email_address varchar(45) not null,
    primary key (email_id, email_address),
    constraint fk_patient_email foreign key (AMKA) references patient (AMKA) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;

create table patient_phone (
    AMKA int unsigned not null,
    phone_number varchar(20) not null,
    primary key (AMKA, phone_number),
    constraint fk_patient_phone foreign key (AMKA) references patient (AMKA) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;


--
-- Table structure for nurse 
--
create table nurse (
    AMKA int unsigned not null,
    first_name varchar(45) not null,
    middle_name varchar(45) not null,
    last_name varchar(45) not null,
    date_of_birth date not null,
    date_of_employment date not null,
    rank enum('Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος') not null,
    dept_name int unsigned not null,
    primary key (AMKA),
    constraint fk_nurse_dept foreign key (dept_name) references department (dept_name) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;

create table nurse_email (
    AMKA int unsigned not null,
    email_address varchar(45) not null,
    primary key (email_id, email_address),
    constraint fk_nurse_email foreign key (AMKA) references nurse (AMKA) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;

create table nurse_phone (
    AMKA int unsigned not null,
    phone_number varchar(20) not null,
    primary key (AMKA, phone_number),
    constraint fk_nurse_phone foreign key (AMKA) references nurse (AMKA) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;


--
-- Table structure for administrative staff 
--
create table administrative_staff (
    AMKA int unsigned not null,
    first_name varchar(45) not null,
    middle_name varchar(45) not null,
    last_name varchar(45) not null,
    date_of_birth date not null,
    date_of_employment date not null,
    role enum('Γραμματεία', 'Λογιστήριο', 'Ανθρώπινο Δυναμικό', 'Τεχνική Υποστήριξη') not null,
    office varchar(10) not null
    dept_name int unsigned not null,
    primary key (AMKA),
    constraint fk_admin_dept foreign key (dept_name) references department (dept_name) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;

create table admin_email (
    AMKA int unsigned not null,
    email_address varchar(45) not null,
    primary key (email_id, email_address),
    constraint fk_admin_email foreign key (AMKA) references admin (AMKA) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;

create table admin_phone (
    AMKA int unsigned not null,
    phone_number varchar(20) not null,
    primary key (AMKA, phone_number),
    constraint fk_admin_phone foreign key (AMKA) references admin (AMKA) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;


--
-- Table structure for doctor 
--
create table doctor (
    AMKA int unsigned not null,
    first_name varchar(45) not null,
    middle_name varchar(45) not null,
    last_name varchar(45) not null,
    date_of_birth date not null,
    date_of_employment date not null,
    dept_name int unsigned not null,
    license_number varchar(20) not null,
    specialty set(),
    primary key (AMKA),
    constraint fk_doctor_dept foreign key (dept_name) references department (dept_name) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;

create table doctor_email (
    AMKA int unsigned not null,
    email_address varchar(45) not null,
    primary key (email_id, email_address),
    constraint fk_doctor_email foreign key (AMKA) references doctor (AMKA) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;

create table doctor_phone (
    AMKA int unsigned not null,
    phone_number varchar(20) not null,
    primary key (AMKA, phone_number),
    constraint fk_doctor_phone foreign key (AMKA) references doctor (AMKA) on delete restrict on update cascade
)engine=InnoDB default charset=utf8;


create table specialisation (
    spec_id varchar(10) not null,
    type varchar(45) not null,
)












SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
