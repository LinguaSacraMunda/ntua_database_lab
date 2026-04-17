import random
from datetime import datetime, timedelta
from faker import Faker
import csv

departments = ["Casualty", "Operating theatre (OT)", "Intensive care unit (ICU)", "Anesthesiology", "Cardiology", "ENT", "Geriatric", "Gastroenterology", "General surgery", "Gynaecology", "Haematology", "Pediatrics", "Neurology", "Oncology", "Opthalmology", "Orthopaedic", "Urology", "Psychiatry", "Inpatient Department (IPD)", "Outpatient Department (OPD)"]

spec_codes = ["AI", "CD", "CG", "END", "GE", "GER", "GS", "HEM", "IC", "ID", "IM", "ISAI", "ISCD", "ISCG", "ISEND", "ISGE", "ISGEN", "ISGER", "ISGS", "ISHEM", "ISIC", "ISID", "ISIM", "ISN", "ISNEP", "ISNIC", "ISOBG", "ISOMS", "ISON", "ISOR", "ISOTO", "ISP", "ISPCS", "ISPDGER", "ISPDGES", "ISPDPED", "ISPED", "ISPEDS", "ISPN", "ISPP", "ISPUL", "ISRHU", "ISRO", "ISTS", "ISU", "N", "NEP", "NIC", "OBG", "OMS", "ON", "OR", "OTO", "P", "PCS", "PDGEN", "PDGER", "PDGES", "PDPED", "PED", "PEDS", "PN", "PP", "PUL", "RHU", "RO", "TS", "U"]

patient_ids = []
nurse_ids = []
admin_ids = []
doctor_ids = []
doctor_dir = []
doctor_senior = []
room_id_beds = []
room_id_surg = []
bed_num = 0;
cost_num = 702;
insurance_carrier_num = 10;

icd10_path = "/home/admin/shared_ntua/6th_semester/databases/project/data/icd10.csv"
ken_path = "/home/admin/shared_ntua/6th_semester/databases/project/data/KEN.csv"


fake = Faker('el_GR')

# ========================================================================
#                              General data
# ========================================================================
def random_date(_start=1940, _end=2000):
    start = datetime(_start, 1, 1);
    end = datetime(_end, 12, 31);
    return start + timedelta(days=random.randint(0, (end - start).days))

def generate_amka(dob):
    base = dob.strftime("%d%m%y")
    return base + f"{random.randint(0, 9999):04d}"

def generate_triage(fdr):
    level = random.randint(1, 5)
    symptoms = fake.text(max_nb_chars=200)
    fdr.write(f"INSERT INTO triage (level, symptoms) VALUES ('{level}', '{symptoms}');\n")

def generate_contacts(fdr, table, amka):
    for i in range(random.randint(1,2)):
        fdr.write(f"INSERT INTO {table}_email (AMKA, phone_number) VALUES ('{amka}', '{fake.email()}');\n")


    for i in range(random.randint(1,3)):
        fdr.write(f"INSERT INTO {table}_phone (AMKA, phone_number) VALUES ('{amka}', '{fake.phone_number()}');\n")


def generate_employment_date(dob):
    start = dob + timedelta(days=365*18) #over 18 years old at time of employment
    end = dob + timedelta(days=365*60)

    if (end > datetime.now()):
        end = datetime.now();

    return start + timedelta(days=random.randint(0, (end-start).days))

def get_icd10():
    with open(icd10_path, newline='\n', encoding='utf-8') as f:
        reader = csv.reader(f);
        hlpr = None;
        for i, row in enumerate(reader, 1):     # this is stupid
            if random.randrange(i) == 0:
                hlpr = row[0];

        return hlpr;


def get_KEN():
    with open(ken_path, newline='\n', encoding='utf-8') as f:
        reader = csv.reader(f);
        next(reader, None)
        hlpr = None;
        for i, row in enumerate(reader, 1):
            if random.randrange(i) == 0:
                hlpr = row[0];

        return hlpr;

# ========================================================================
#                               Patient Gen 
# ========================================================================
def generate_patient(fdr, triage_id):
    dob = random_date(1940, 2025);
    amka = generate_amka(dob);
    patient_ids.append(amka)

    first_name = fake.first_name()
    if (random.random() < 0.2):
        middle_name = fake.first_name()
    else:
        middle_name = None 
    last_name = fake.last_name()

    sex = random.choice(['male', 'female', 'other'])

    weight = round(random.uniform(50, 150), 2)
    height = round(random.uniform(50, 200), 2)

    street_name = fake.street_name()
    street_number = str(random.randint(1, 200))
    postal_code = fake.postcode()
    area = fake.city()
    municipality = fake.city()
    prefecture = fake.region()

    profession = fake.job()
    citizenship = fake.country()

    fdr.write(f"INSERT INTO patient (AMKA, first_name, middle_name, last_name, date_of_birth, sex, weight, height, street_name, street_number, postal_code, area, municipality, prefecture,  profession, citizenship, triage_id) VALUES ('{amka}','{first_name}',{'NULL' if middle_name is None else '\'' + str(middle_name) + '\''},'{last_name}','{dob.date()}','{sex}','{weight}','{height}','{street_name}','{street_number}','{postal_code}','{area}','{municipality}','{prefecture}','{profession}','{citizenship}','{triage_id}');\n")

    return amka

# ========================================================================
#                               Nurse Gen 
# ========================================================================
def generate_nurse(fdr):
    dob = random_date()
    doe = generate_employment_date(dob)
    amka = generate_amka(dob)
    nurse_ids.append(amka)

    first_name = fake.first_name()
    if (random.random() < 0.2):
        middle_name = fake.first_name()
    else:
        middle_name = None 
    last_name = fake.last_name()

    rank = random.choice(['Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος'])

    dept_name = random.choice(departments)

    fdr.write(f"INSERT INTO nurse (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, rank, dept_name) VALUES ('{amka}', '{first_name}', {'NULL' if middle_name is None else '\''+str(middle_name)+'\''}, '{last_name}', '{dob.date()}', '{doe.date()}', '{rank}', '{dept_name}');\n")

    return amka

# ========================================================================
#                               Admin Gen 
# ========================================================================
def generate_admin(fdr):
    dob = random_date()
    doe = generate_employment_date(dob)
    amka = generate_amka(dob)
    admin_ids.append(amka)

    first_name = fake.first_name()
    if (random.random() < 0.2):
        middle_name = fake.first_name()
    else:
        middle_name = None 
    last_name = fake.last_name()

    role = random.choice(['Γραμματεία', 'Λογιστήριο', 'Ανθρώπινο Δυναμικό', 'Τεχνική Υποστήριξη'])

    office = fake.building_number()

    dept_name = random.choice(departments)

    fdr.write(f"INSERT INTO administrative_staff (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, role, office, dept_name) VALUES ('{amka}', '{first_name}', {'NULL' if middle_name is None else '\''+str(middle_name)+'\''}, '{last_name}', '{dob.date()}', '{doe.date()}', '{role}', '{office}', '{dept_name}');\n")

    return amka

# ========================================================================
#                               Doctor Gen 
# ========================================================================
def generate_doctor(fdr):
    dob = random_date()
    doe = generate_employment_date(dob)
    amka = generate_amka(dob)
    doctor_ids.append(amka)

    first_name = fake.first_name()
    if (random.random() < 0.2):
        middle_name = fake.first_name()
    else:
        middle_name = None 
    last_name = fake.last_name()

    rank = random.choice(['Ειδικευόμενος', 'Επιμελητής Β', 'Επιμελητής Α', 'Διευθυντής'])

    # Make sure there are enough directors to assign
    # to every department
    if (len(departments) > len(doctor_dir)):
        rank = 'Διευθυντής'

    if (rank != 'Ειδικευόμενος'):
        doctor_senior.append(amka)
    if (rank == 'Διευθυντής'):
        doctor_dir.append(amka)

    license_num = f"{random.randint(0, 9999999999):010d}"

    fdr.write(f"INSERT INTO doctor (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, license_number, rank) VALUES ('{amka}', '{first_name}', {'NULL' if middle_name is None else '\''+str(middle_name)+'\''}, '{last_name}', '{dob.date()}', '{doe.date()}', '{license_num}', '{rank}');\n")

    return amka

def generate_supervision(fdr, amka):
    super = random.choice(doctor_senior)
    fdr.write(f"UPDATE doctor SET supervisor_id = '{super}' WHERE AMKA = {amka};\n")

def generate_specialisation(fdr, amka):
    spec = random.choice(spec_codes)
    fdr.write(f"INSERT INTO doc_spec (AMKA, spec_code) VALUES ('{amka}', '{spec}');\n")

# ========================================================================
#                           Department Gen 
# ========================================================================

def assign_to_department(fdr, table, amka):
    fdr.write(f"INSERT INTO {table}_dept (AMKA, dept_name) VALUES ('{amka}', '{random.choice(departments)}');\n")

def generate_departments(fdr):
    for iter in departments:
        dept_name = iter 
        description = fake.text(max_nb_chars=200)
        number_of_beds = random.randint(20, 200)
        floor = random.randint(-2, 10)
        building = f"Κτήριο {fake.last_name()}"
        director_id = doctor_dir.pop()
        
        fdr.write(f"INSERT INTO department (dept_name, description, number_of_beds, floor, building, director_id) VALUES ('{dept_name}', '{description}', '{number_of_beds}', '{floor}', '{building}', '{director_id}');\n")

        assign_to_department(fdr, "doctor", director_id)


# ========================================================================
#                               Room Gen 
# ========================================================================
room_ids = []

def generate_room(fdr):
    if (len(room_ids) == 0):
        room_id = 1
    else:
        room_id = room_ids[len(room_ids)-1] + 1

    room_ids.append(room_id)
    type_t = random.choice(['Κλίνες', 'Χειρουργική Αίθουσα', 'ΤΕΠ', 'Διαγνωστική Αίθουσα', 'Αίθουσα Αναμονής', 'Γραφείο', 'Αποθήκη'])
    status = random.choice(['Διαθέσιμο', 'Κατειλημμένο', 'Υπό Συντήρηση'])
    dept_name = random.choice(departments)

    if (type_t == 'Κλίνες'):
        room_id_beds.append(room_id)
    if (type_t == 'Χειρουργική Αίθουσα'):
        room_id_surg.append(room_id)

    fdr.write(f"INSERT INTO room (type, status, dept_name) VALUES ('{type_t}', '{status}', '{dept_name}');\n")


# ========================================================================
#                               Bed Gen 
# ========================================================================

def generate_bed(fdr):
    type_t = random.choice(['ΜΕΘ', 'Μονόκλινο', 'Πολύκλινο', 'ΜΕΝΝ', 'Θάλαμος Νοσηλείας'])
    status = random.choice(['Διαθέσιμη', 'Κατειλημμένη', 'Υπό Συντήρηση'])
    dept_name = random.choice(departments)
    room_id = room_id_beds.pop()

    fdr.write(f"INSERT INTO bed (type, status, dept_name, room_id) VALUES ('{type_t}', '{status}', '{dept_name}', '{room_id}');\n")


# ========================================================================
#                             Equipment Gen 
# ========================================================================
equip_ids = []
def generate_equipment(fdr):
    uid = fake.uuid4()
    description = fake.text(max_nb_chars=200)
    room_id = random.choice(room_ids)
    dept_name = random.choice(departments)

    equip_ids.append(uid)

    fdr.write(f"INSERT INTO equipment (UID, description, room_id, dept_name) VALUES ('{uid}', '{description}', '{room_id}', '{dept_name}');\n")

# ========================================================================
#                            Insurance Gen 
# ========================================================================

def generate_insurance(fdr):
    name = fake.company()
    fdr.write(f"INSERT INTO insurance_carrier (name) VALUES ('{name}');\n")

def assign_to_carrier(fdr, lim, amka):
    carrier_id = random.randint(1, lim);
    fdr.write(f"INSERT INTO patient_insurance (AMKA, carrier_id) VALUES ('{amka}', '{carrier_id}');\n")

# ========================================================================
#                              Allergy Gen 
# ========================================================================

def generate_allergy(fdr, lim, amka):
    # 60% to not have allegries
    if (random.random() < 0.6):
        return;

    for i in range(random.randint(1, 4)):
        act_sub_id = random.randint(1, lim)
        fdr.write(f"INSERT INTO patient_allergy (AMKA, act_sub_id) VALUES ('{amka}', '{act_sub_id}');\n")


# ========================================================================
#                               Media Gen 
# ========================================================================
media_num = 0;
def generate_media_aux(fdr):
    path = f"/media/images/image_{Faker('en_GB').word()}.{random.choice(['jpg', 'png', 'jpeg'])}"
    description = fake.text(max_nb_chars=200)

    fdr.write(f"INSERT INTO media (path, description) VALUES ('{path}', '{description}');\n")
    media_num += 1;

def generate_media(fdr, table, id):
    generate_media_aux(fdr)

    fdr.write(f"INSERT INTO {table}_media (media_id, {table}_id) VALUES ('{media_num}', '{table}_id')")

# ========================================================================
#                             Hospitalisation 
# ========================================================================
hosp_id = 0;
def generate_hospitalisation(fdr):
    hosp_id += 1;
    admission_date = random_date(1990, 2025)
    generate_admission_diag(fdr, hosp_id)
    if (random.random() < 0.5):
        discharge_date = random_date(admission_date.year + 1, 2025)
        generate_discharge_diag(fdr, hosp_id)
    else:
        discharge_date = None
    dept_name = random.choice(departments)
    bed_id = random.randint(1, bed_num + 1)
    costing_id = random.randint(1, cost_num + 1)

    fdr.write(f"INSERT INTO hospitalisation (admission_date, discharge_date, dept_name, bed_id, costing_id) VALUES ('{admission_date.date()}', {'NULL' if discharge_date is None else '\'' + str(discharge_date.date()) + '\''}, '{dept_name}', '{bed_id}', '{costing_id}');\n")

def assign_hospitalisation(fdr, _hosp_id):
    amka = random.choice(patient_ids)
    fdr.write(f"INSERT INTO patient_record (AMKA, hosp_id) VALUES ('{amka}', '{_hosp_id}');\n")

def generate_admission_diag(fdr, _hosp_id):
    daig_id = get_icd10()
    fdr.write(f"INSERT INTO admission_diagnosis (hosp_id, diag_id) VALUES ('{_hosp_id}', '{diag_id}');\n")


def generate_discharge_diag(fdr, _hosp_id):
    daig_id = get_icd10()
    fdr.write(f"INSERT INTO discharge_diagnosis (hosp_id, diag_id) VALUES ('{_hosp_id}', '{diag_id}');\n")

def assign_coverage(fdr, _hosp_id):
    carrier_id = random.randint(1, insurance_carrier_num + 1)
    fdr.write(f"INSERT INTO hospit_coverage (hosp_id, carrier_id) VALUES ('{_hosp_id}', '{carrier_id}');\n")


# ========================================================================
#                                 Main 
# ========================================================================

def main():
    patient_num = 200;
    doctor_num = 80;
    nurse_num = 100;
    admin_num = 50;
    room_num = 150;
    act_sub_num = 12000;
    equip_num = 250;
    hosp_num = patient_num + 100;

    with open("insert.sql", "w") as fdr:
        fdr.write("SET FOREIGN_KEY_CHECKS = 0;\n")

        for _ in range(patient_num):
            triage_id = generate_triage(fdr)
            amka = generate_patient(fdr, triage_id)
            generate_contacts(fdr, "patient", amka)

        for _ in range(nurse_num):
            amka = generate_nurse(fdr)
            generate_contacts(fdr, "nurse", amka)
            assign_to_department(fdr, "nurse", amka)

        for _ in range(admin_num):
            amka = generate_admin(fdr)
            generate_contacts(fdr, "admin", amka)
            assign_to_department(fdr, "admin", amka)

        for _ in range(doctor_num):
            amka = generate_doctor(fdr)
            generate_contacts(fdr, "doctor", amka)
            assign_to_department(fdr, "doctor", amka)
            for i in range(random.randint(1,2)):
                generate_specialisation(fdr, amka)

        for i in list(set(doctor_ids) - set(doctor_dir)):
            if (random.random() < 0.7):
                generate_supervision(fdr, i)

        generate_departments(fdr)

        for i in nurse_ids:
            assign_to_department(fdr, "nurse", i)
        for i in admin_ids:
            assign_to_department(fdr, "admin", i)
        for i in list(set(doctor_ids) - set(doctor_dir)):
            assign_to_department(fdr, "doctor", i)


        for _ in range(room_num):
            generate_room(fdr)

        bed_num = len(room_id_beds)
        for _ in range(bed_num):
            generate_bed(fdr)

        for _ in range(equip_num):
            generate_equipment(fdr)

        fdr.write(f"INSERT INTO insurance_carrier (name) VALUES ('Ανασφάλιστος');\n")
        for _ in range(insurance_carrier_num - 1):
            generate_insurance(fdr)

        for i in patient_ids:
            assign_to_carrier(fdr, insurance_carrier_num, i)
            generate_allergy(fdr, act_sub_num, i)


        for i in doctor_ids:
            generate_media(fdr, "doctor", i)

        for i in nurse_ids:
            generate_media(fdr, "nurse", i)

        for i in admin_ids:
            generate_media(fdr, "admin", i)

        for i in equip_ids:
            generate_media(fdr, "equipment", i)

        for i in range(1, bed_num + 1):
            generate_media(fdr, "bed", i)

        for i in range(1, room_num + 1):
            generate_media(fdr, "room", i)

        for _ in range(hosp_num):
            generate_hospitalisation(fdr)

        for i in range(1, hosp_num + 1):
            assign_hospitalisation(fdr, i)


        fdr.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        fdr.close()

if __name__ == "__main__":
    main()
