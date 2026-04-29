import random
from datetime import datetime, timedelta
from faker import Faker
import csv
from collections import defaultdict


departments = ["Casualty", "Operating theatre (OT)", "Intensive care unit (ICU)", "Anesthesiology", "Cardiology", "ENT", "Geriatric", "Gastroenterology", "General surgery", "Gynaecology", "Haematology", "Pediatrics", "Neurology", "Oncology", "Opthalmology", "Orthopaedic", "Urology", "Psychiatry", "Inpatient Department (IPD)", "Outpatient Department (OPD)"]

spec_codes = ["AI", "CD", "CG", "END", "GE", "GER", "GS", "HEM", "IC", "ID", "IM", "ISAI", "ISCD", "ISCG", "ISEND", "ISGE", "ISGEN", "ISGER", "ISGS", "ISHEM", "ISIC", "ISID", "ISIM", "ISN", "ISNEP", "ISNIC", "ISOBG", "ISOMS", "ISON", "ISOR", "ISOTO", "ISP", "ISPCS", "ISPDGER", "ISPDGES", "ISPDPED", "ISPED", "ISPEDS", "ISPN", "ISPP", "ISPUL", "ISRHU", "ISRO", "ISTS", "ISU", "N", "NEP", "NIC", "OBG", "OMS", "ON", "OR", "OTO", "P", "PCS", "PDGEN", "PDGER", "PDGES", "PDPED", "PED", "PEDS", "PN", "PP", "PUL", "RHU", "RO", "TS", "U"]

tables = ["admin_email", "admin_media", "admin_phone", "admin_shift", "administrative_staff", "admission_diagnosis", "bed", "bed_media", "department", "dept_shift", "discharge_diagnosis", "doc_spec", "doctor", "doctor_dept", "doctor_email", "doctor_media", "doctor_phone", "doctor_shift", "emergency_contact", "equipment", "equipment_media", "hosp_lab_test", "hosp_med_act", "hospitalisation", "insurance_carrier", "lab_test", "media", "medical_act", "nurse", "nurse_email", "nurse_media", "nurse_phone", "nurse_shift", "patient", "patient_allergy", "patient_email", "patient_insurance", "patient_phone", "patient_record", "prescribed_products", "prescription", "rating", "room", "room_media", "shift", "surgical_act", "surgical_act_doctor_assistants", "surgical_act_nurse_assistants", "triage", "hosp_prescription", "patient_triage"]


patient_ids = []
nurse_ids = []
admin_ids = []
doctor_ids = []
doctor_dir = []
doctor_senior = []
room_ids = []
room_id_beds = []
room_id_surg = []
patient_triages = defaultdict(list)
valid_keys = []
bed_num = 0;
cost_num = 702;
insurance_carrier_num = 10;
patient_num = 200;
doctor_num = 80;
nurse_num = 100;
admin_num = 50;
room_num = 150;
act_sub_num = 12000;
equip_num = 250;
hosp_num = 2 * patient_num;
med_proc_num = 11019
pharm_prod_num = 162000
prescr_num = round(1.4 * patient_num)

DISABLE_FK_CHECK = True

Q03_SAME_DEPT = 5;

TEMP = "/home/admin/shared_ntua/6th_semester/databases/project/"

icd10_path = TEMP + "data/icd10.csv"
ken_path = TEMP + "data/KEN.csv"
pharm_prod_path = TEMP + "data/article-57-product-data_en_clean.csv"

fake = Faker('el_GR')

# Auto_increment ids as global vars
triage_id = 0;
bed_id = 0;
shift_id = 0;
hosp_id = 0;
lab_test_id = 0;
prescr_id = 0;
media_num = 0;


# ========================================================================
#                              General data
# ========================================================================
def random_date(_start=1940, _end=2026):
    start = datetime(_start, 1, 1);
    end = datetime(_end, 12, 31);
    return start + timedelta(days=random.randint(0, (end - start).days))

def generate_amka(dob):
    base = dob.strftime("%d%m%y")
    return base + f"{random.randint(0, 9999):04d}"

def generate_triage(fdr):
    global triage_id;
    triage_id += 1;
    level = random.randint(1, 5)
    symptoms = fake.text(max_nb_chars=200)
    fdr.write(f"INSERT INTO triage (triage_id, level, symptoms) VALUES ('{triage_id}', '{level}', '{symptoms}');\n")

    return triage_id

def generate_contacts(fdr, table, amka):
    for i in range(random.randint(1,2)):
        fdr.write(f"INSERT INTO {table}_email (AMKA, email_address) VALUES ('{amka}', '{fake.email()}');\n")


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

def get_pharm_prod():
    with open(pharm_prod_path, newline='\n', encoding='utf-8') as f:
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
def generate_patient(fdr):
    dob = random_date(1940, 2025);
    amka = generate_amka(dob);
    patient_ids.append(amka)

    first_name = fake.first_name()
    if (random.random() < 0.2):
        middle_name = fake.first_name()
    else:
        middle_name = None 
    last_name = fake.last_name()

    patronym = fake.first_name()

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

    fdr.write(f"INSERT INTO patient (AMKA, first_name, middle_name, last_name, patronym, date_of_birth, sex, weight, height, street_name, street_number, postal_code, area, municipality, prefecture,  profession, citizenship) VALUES ('{amka}','{first_name}',{'NULL' if middle_name is None else '\'' + str(middle_name) + '\''},'{last_name}', '{patronym}', '{dob.date()}','{sex}','{weight}','{height}','{street_name}','{street_number}','{postal_code}','{area}','{municipality}','{prefecture}','{profession}','{citizenship}');\n")

    for _ in range(random.randint(5,10)):
            _triage_id = generate_triage(fdr)
            fdr.write(f"INSERT INTO patient_triage (AMKA, triage_id) VALUES ('{amka}', '{_triage_id}');\n")
            patient_triages[amka].append(_triage_id);

    return amka

# ========================================================================
#                               Nurse Gen 
# ========================================================================
def generate_nurse(fdr):
    dob = random_date(1940, 2000)
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
    dob = random_date(1940, 2000)
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
    dob = random_date(1940, 2000)
    doe = generate_employment_date(dob)
    amka = generate_amka(dob)
    doctor_ids.append(amka)
    supervisor_id = None

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
    else:
        supervisor_id = random.choice(doctor_senior)
    if (rank == 'Διευθυντής'):
        doctor_dir.append(amka)

    license_num = f"{random.randint(0, 9999999999):010d}"

    fdr.write(f"INSERT INTO doctor (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, license_number, rank, supervisor_id) VALUES ('{amka}', '{first_name}', {'NULL' if middle_name is None else '\''+str(middle_name)+'\''}, '{last_name}', '{dob.date()}', '{doe.date()}', '{license_num}', '{rank}', {'NULL' if supervisor_id is None else '\''+str(supervisor_id)+'\''});\n")

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

    fdr.write(f"INSERT INTO room (room_id, type, status, dept_name) VALUES ('{room_id}', '{type_t}', '{status}', '{dept_name}');\n")


# ========================================================================
#                               Bed Gen 
# ========================================================================

def generate_bed(fdr):
    global bed_id;
    bed_id += 1;
    type_t = random.choice(['ΜΕΘ', 'Μονόκλινο', 'Πολύκλινο', 'ΜΕΝΝ', 'Θάλαμος Νοσηλείας'])
    status = random.choice(['Διαθέσιμη', 'Κατειλημμένη', 'Υπό Συντήρηση'])
    dept_name = random.choice(departments)
    room_id = room_id_beds.pop()

    fdr.write(f"INSERT INTO bed (bed_id, type, status, dept_name, room_id) VALUES ('{bed_id}', '{type_t}', '{status}', '{dept_name}', '{room_id}');\n")


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

def generate_insurance(fdr, id):
    name = fake.company()
    fdr.write(f"INSERT INTO insurance_carrier (carrier_id, name) VALUES ('{id}', '{name}');\n")

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

def generate_media_aux(fdr):
    global media_num;
    media_num += 1;
    path = f"/media/images/image_{Faker('en_GB').word()}.{random.choice(['jpg', 'png', 'jpeg'])}"
    description = fake.text(max_nb_chars=200)

    fdr.write(f"INSERT INTO media (media_id, path, description) VALUES ('{media_num}', '{path}', '{description}');\n")

def generate_media(fdr, table, id):
    generate_media_aux(fdr)

    fdr.write(f"INSERT INTO {table}_media (media_id, {table}_id) VALUES ('{media_num}', '{id}');\n")

# ========================================================================
#                             Lab Test Gen 
# ========================================================================

def generate_lab_test(fdr):
    global lab_test_id;
    lab_test_id += 1;
    med_proc_id = random.randint(6609, med_proc_num)
    doc_id = random.choice(doctor_ids)
    date = random_date(_start=2020, _end=2026)
    result = fake.text(max_nb_chars=200)
    cost = round(random.uniform(10, 9999), 2)

    fdr.write(f"INSERT INTO lab_test (lab_test_id, med_proc_id, doc_id, date, result, cost) VALUES ('{lab_test_id}', '{med_proc_id}', '{doc_id}', '{date}', '{result}', '{cost}');\n")
    return lab_test_id

def assign_hosp_to_lab_test(fdr, _hosp_id, _lab_test_id):
    fdr.write(f"INSERT INTO hosp_lab_test (lab_test_id, hosp_id) VALUES ('{_lab_test_id}', '{_hosp_id}');\n")

# ========================================================================
#                           Medical Act Gen 
# ========================================================================
med_act_id = 0;

def is_surgical_act(fdr, _med_act_id, _primary_doc=None):
    primary_doc = _primary_doc if _primary_doc != None else random.choice(doctor_senior)
    fdr.write(f"INSERT INTO surgical_act (med_act_id, primary_doc_id) VALUES ('{_med_act_id}', '{primary_doc}');\n")

    # Assistants
    for _ in range(random.randint(1,2)):
        hlpr = random.choice(doctor_ids)
        fdr.write(f"INSERT INTO surgical_act_doctor_assistants (med_act_id, assistant_id) VALUES ('{_med_act_id}', '{hlpr}');\n")

    for _ in range(random.randint(1,3)):
        hlpr = random.choice(nurse_ids)
        fdr.write(f"INSERT INTO surgical_act_nurse_assistants (med_act_id, assistant_id) VALUES ('{_med_act_id}', '{hlpr}');\n")



def generate_med_act(fdr):
    global med_act_id;
    med_act_id += 1;
    type_t = random.choice(['Χειρουργική', 'Διαγνωστική', 'Θεραπευτική'])
    med_proc_id = random.randint(1, 6608)
    start_datetime = random_date(_start=2020, _end=2026)
    result = fake.text(max_nb_chars=200)
    cost = round(random.uniform(10, 9999), 2)

    if (type_t == 'Χειρουργική'):
        start_datetime = random_date(_start=2025, _end=2026)
        room_id = random.choice(room_id_surg)
        is_surgical_act(fdr, med_act_id)
    else:
        room_id = random.choice(room_ids)

    end_datetime = start_datetime + timedelta(days=random.randint(1, 100), hours=random.randint(1,10))

    fdr.write(f"INSERT INTO medical_act (med_act_id, type, med_proc_id, start_datetime, end_datetime, room_id, cost) VALUES ('{med_act_id}', '{type_t}', '{med_proc_id}', '{start_datetime}', '{end_datetime}', '{room_id}', '{cost}');\n")
    return med_act_id


def assign_hosp_to_med_act(fdr, _hosp_id, _med_act_id):
    fdr.write(f"INSERT INTO hosp_med_act (med_act_id, hosp_id) VALUES ('{_med_act_id}', '{_hosp_id}');\n")

# ========================================================================
#                             Rating Gen 
# ========================================================================

def generate_rating(fdr,_hosp_id, amka):
    medical_care = random.randint(1,5)
    nursing_care = random.randint(1,5)
    cleanliness = random.randint(1,5)
    food = random.randint(1,5)
    experience = random.randint(1,5)

    fdr.write(f"INSERT INTO rating (AMKA, hosp_id, medical_care, nursing_care, cleanliness, food, experience) VALUES ('{amka}', '{_hosp_id}', '{medical_care}', '{nursing_care}', '{cleanliness}', '{food}', '{experience}');\n")


# ========================================================================
#                             Hospitalisation 
# ========================================================================

def assign_to_patient_record(fdr, _hosp_id, _amka=None):
    valid_keys = [k for k, v in patient_triages.items() if v]  # non-empty lists
    amka = _amka if _amka != None else random.choice(valid_keys)
    fdr.write(f"INSERT INTO patient_record (AMKA, hosp_id) VALUES ('{amka}', '{_hosp_id}');\n")
    return amka;

def generate_admission_diag(fdr, _hosp_id):
    diag_id = get_icd10()
    fdr.write(f"INSERT INTO admission_diagnosis (hosp_id, diag_id) VALUES ('{_hosp_id}', '{diag_id}');\n")

def generate_discharge_diag(fdr, _hosp_id):
    diag_id = get_icd10()
    fdr.write(f"INSERT INTO discharge_diagnosis (hosp_id, diag_id) VALUES ('{_hosp_id}', '{diag_id}');\n")

def update_triage(fdr, _arrival_time, _triage_id):
    fdr.write(f"UPDATE triage SET status = TRUE, arrival_time = '{_arrival_time}' WHERE triage_id = '{_triage_id}';\n")
    return _triage_id;

def generate_hospitalisation(fdr, _dept=None):
    global hosp_id;
    hosp_id += 1;
    admission_date = random_date(_start=2020, _end=2026)
    generate_admission_diag(fdr, hosp_id)
    if (random.random() < 0.5):
        discharge_date = admission_date + timedelta(days=random.randint(1, 100))
        generate_discharge_diag(fdr, hosp_id)
    else:
        discharge_date = None
    dept_name = _dept if (_dept != None) else random.choice(departments)
    bed_id = random.randint(1, bed_num)
    costing_id = random.randint(1, cost_num)
    carrier_id = random.randint(1, insurance_carrier_num)

    amka = assign_to_patient_record(fdr, hosp_id)
    _triage_id = update_triage(fdr, admission_date - timedelta(minutes=random.randint(15, 300)), patient_triages[amka].pop());


    fdr.write(f"INSERT INTO hospitalisation (hosp_id, admission_date, discharge_date, dept_name, bed_id, costing_id, carrier_id, triage_id) VALUES ('{hosp_id}', '{admission_date.date()}', {'NULL' if discharge_date is None else '\'' + str(discharge_date.date()) + '\''}, '{dept_name}', '{bed_id}', '{costing_id}', '{carrier_id}', '{_triage_id}');\n")

    # Lab test
    if (random.random() < 0.6):
        test_id = generate_lab_test(fdr)
        assign_hosp_to_lab_test(fdr, hosp_id, test_id)

    # Medical act
    if (random.random() < 0.8):
        act_id = generate_med_act(fdr)
        assign_hosp_to_med_act(fdr, hosp_id, act_id)

    if (_dept != None):
        return hosp_id, discharge_date

    if (discharge_date != None):
        generate_rating(fdr, hosp_id, amka)
    

    # Prescription
    if (random.random() < 0.6):
        for _ in range(random.randint(1,6)):
            prescr_id = generate_prescription(fdr, amka)
            assign_hosp_prescription(fdr, hosp_id, prescr_id)

# ========================================================================
#                           Prescription Gen 
# ========================================================================

def prescribe_prods(fdr, _prescr_id):
    pharm_prod_id = random.randint(1, pharm_prod_num)
    start_date = random_date(_start=2020, _end=2026)
    end_date = start_date + timedelta(days=random.randint(1, 60))
    dosage = fake.text(max_nb_chars=200)
    frequency = fake.text(max_nb_chars=80)

    fdr.write(f"INSERT INTO prescribed_products (prescription_id, pharm_prod_id, start_date, end_date, dosage, frequency) VALUES ('{_prescr_id}', '{pharm_prod_id}', '{start_date}', '{end_date}', '{dosage}', '{frequency}');\n")

def generate_prescription(fdr, _patient=None):
    global prescr_id;
    prescr_id += 1;
    doctor_id = random.choice(doctor_ids)
    patient_id = _patient if _patient != None else random.choice(patient_ids)

    fdr.write(f"INSERT INTO prescription (prescription_id, doctor_id, patient_id) VALUES ('{prescr_id}', '{doctor_id}', '{patient_id}');\n")

    for _ in range(random.randint(1, 10)):
        prescribe_prods(fdr, prescr_id)

    return prescr_id;

def assign_hosp_prescription(fdr, _hosp_id, _prescr_id):
    fdr.write(f"INSERT INTO hosp_prescription (hosp_id, prescription_id) VALUES ('{_hosp_id}', '{_prescr_id}');\n")

# ========================================================================
#                               Shift Gen 
# ========================================================================

def assign_shift_staff(fdr, table, amka, _shift_id):
    fdr.write(f"INSERT IGNORE INTO {table}_shift (AMKA, shift_id) VALUES ('{amka}', '{_shift_id}');\n")

def generate_shift(fdr, _type=None, _day=None):
    global shift_id;
    shift_id += 1;
    day = None;
    type_t = None;
    if (_type == None or _day == None):
        day = random_date(_start=2024, _end=2026)
        type_t = random.choice(['07:00-15:00', '15:00-23:00', '23:00-07:00'])
    else:
        day = _day
        type_t = _type

    fdr.write(f"INSERT INTO shift (shift_id, day, type) VALUES ('{shift_id}', '{day}', '{type_t}');\n")

    d = random.sample(doctor_ids, random.randint(3, min(8, len(doctor_ids))))
    n = random.sample(nurse_ids, random.randint(6, min(10, len(nurse_ids))))
    a = random.sample(admin_ids, random.randint(2, min(4, len(admin_ids))))

    for i in d:
        assign_shift_staff(fdr, "doctor", i, shift_id)
    for i in n:
        assign_shift_staff(fdr, "nurse", i, shift_id)
    for i in a:
        assign_shift_staff(fdr, "admin", i, shift_id)

    fdr.write(f"UPDATE IGNORE shift SET status = TRUE WHERE shift_id = '{shift_id}';\n")

    return shift_id;

def generate_dept_shifts_aux(fdr, dept_name):
    day = random_date(_start=2024, _end=2026)
    _shift_id = generate_shift(fdr,'07:00-15:00', day);
    fdr.write(f"INSERT IGNORE INTO dept_shift (dept_name, shift_id) VALUES ('{dept_name}', '{_shift_id}');\n")
    _shift_id = generate_shift(fdr,'15:00-23:00', day);
    fdr.write(f"INSERT IGNORE INTO dept_shift (dept_name, shift_id) VALUES ('{dept_name}', '{_shift_id}');\n")
    _shift_id = generate_shift(fdr,'23:00-07:00', day);
    fdr.write(f"INSERT IGNORE INTO dept_shift (dept_name, shift_id) VALUES ('{dept_name}', '{_shift_id}');\n")


def generate_dept_shifts(fdr):
    for i in departments:
        for _ in range(random.randint(10, 20)):
            generate_dept_shifts_aux(fdr, i)
    

# ========================================================================
#                                 Main 
# ========================================================================
def clear_tables(fdr):
    for i in tables:
        fdr.write(f"TRUNCATE TABLE {i};\n")
    


def main():
    with open("insert.sql", "w") as fdr:
        if (DISABLE_FK_CHECK):
            fdr.write("SET FOREIGN_KEY_CHECKS = 0;\n")

        clear_tables(fdr)

        for _ in range(patient_num):
            amka = generate_patient(fdr)
            generate_contacts(fdr, "patient", amka)

        for _ in range(nurse_num):
            amka = generate_nurse(fdr)
            generate_contacts(fdr, "nurse", amka)

        for _ in range(admin_num):
            amka = generate_admin(fdr)
            generate_contacts(fdr, "admin", amka)

        for _ in range(doctor_num):
            amka = generate_doctor(fdr)
            generate_contacts(fdr, "doctor", amka)
            assign_to_department(fdr, "doctor", amka)
            for i in range(random.randint(1,2)):
                generate_specialisation(fdr, amka)

        doctor_jr_ids = list(set(doctor_ids) - set(doctor_senior))
        for i in list(set(doctor_ids) - set(doctor_dir) - set(doctor_jr_ids)):
            if (random.random() < 0.7):
                generate_supervision(fdr, i)

        generate_departments(fdr)

        #for i in list(set(doctor_ids) - set(doctor_dir)):
        #    assign_to_department(fdr, "doctor", i)


        for _ in range(room_num):
            generate_room(fdr)

        global bed_num;
        bed_num = len(room_id_beds)
        for _ in range(bed_num):
            generate_bed(fdr)

        for _ in range(equip_num):
            generate_equipment(fdr)

        fdr.write(f"INSERT INTO insurance_carrier (carrier_id, name) VALUES (1, 'Ανασφάλιστος');\n")
        for i in range(insurance_carrier_num - 1):
            generate_insurance(fdr, i + 2)

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

        for _ in range(Q03_SAME_DEPT):
            _dept = random.choice(departments)
            _amka = random.choice(patient_ids)
            for i in range(random.randint(3,6)):
                hosp_id_t, dd_t = generate_hospitalisation(fdr, _dept)
                assign_to_patient_record(fdr, hosp_id_t)
                if (dd_t != None):
                    generate_rating(fdr, hosp_id_t, _amka)

        for _ in range(prescr_num):
            generate_prescription(fdr)

        generate_dept_shifts(fdr)

        if (DISABLE_FK_CHECK):
            fdr.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        fdr.close()

if __name__ == "__main__":
    main()
