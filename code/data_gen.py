import random
from datetime import datetime, timedelta
from faker import Faker

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

fake = Faker('el_GR')

# ========================================================================
#                              General data
# ========================================================================
def random_date(_start=1940, _end=2025):
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

# ========================================================================
#                               Patient Gen 
# ========================================================================
def generate_patient(fdr, triage_id):
    dob = random_date();
    amka = generate_amka(dob);
    patient_ids.append(amka)

    first_name = fake.first_name()
    if (random.random() < 0.2):
        middle_name = fake.first_name
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

    fdr.write(f"INSERT INTO patient (AMKA, first_name, middle_name, last_name, date_of_birth, sex, weight, height, street_name, street_number, postal_code, area, municipality, prefecture,  profession, citizenship, triage_id) VALUES ('{amka}','{first_name}','{middle_name}','{last_name}','{dob.date()}','{sex}','{weight}','{height}','{street_name}','{street_number}','{postal_code}','{area}','{municipality}','{prefecture}','{profession}','{citizenship}','{triage_id}');\n")
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
        middle_name = fake.first_name
    else:
        middle_name = None 
    last_name = fake.last_name()

    rank = random.choice(['Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος'])

    dept_name = random.choice(departments)

    fdr.write(f"INSERT INTO nurse (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, rank, dept_name) VALUES ('{amka}', '{first_name}', '{middle_name}', '{last_name}', '{dob.date()}', '{doe.date()}', '{rank}', '{dept_name}');\n")

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
        middle_name = fake.first_name
    else:
        middle_name = None 
    last_name = fake.last_name()

    role = random.choice(['Γραμματεία', 'Λογιστήριο', 'Ανθρώπινο Δυναμικό', 'Τεχνική Υποστήριξη'])

    office = fake.building_number()

    dept_name = random.choice(departments)

    fdr.write(f"INSERT INTO administrative_staff (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, role, office, dept_name) VALUES ('{amka}', '{first_name}', '{middle_name}', '{last_name}', '{dob.date()}', '{doe.date()}', '{role}', '{office}', '{dept_name}');\n")

# ========================================================================
#                               Doctor Gen 
# ========================================================================
def generate_nurse(fdr):
    dob = random_date()
    doe = generate_employment_date(dob)
    amka = generate_amka(dob)
    doctor_ids.append(amka)

    first_name = fake.first_name()
    if (random.random() < 0.2):
        middle_name = fake.first_name
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

    fdr.write(f"INSERT INTO doctor (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, license_number, rank) VALUES ('{amka}', '{first_name}', '{middle_name}', '{last_name}', '{dob.date()}', '{doe.date()}', '{license_num}', '{rank}');\n")

def generate_supervision(fdr, amka):
    super = random.choice(doctor_senior)
    fdr.write(f"UPDATE doctor SET supervisor_id = '{super}' WHERE AMKA = {amka}")

def generate_specialisation(fdr, amka):
    spec = random.choice(spec_codes)
    fdr.write(f"INSERT INTO doc_spec (AMKA, spec_code) VALUES ('{amka}', '{spec}');\n")

# ========================================================================
#                           Department Gen 
# ========================================================================

def generate_departments(fdr):
    for iter in departments:
        dept_name = iter 
        description = fake.text(max_nb_chars=200)
        number_of_beds = random.randint(20, 200)
        floor = random.randin(-2, 10)
        building = f"Κτήριο {fake.last_name()}"
        director_id = doctor_dir.pop()
        
        fdr.write(f"INSERT INTO department (dept_name, description, number_of_beds, floor, building, director_id) VALUES ('{dept_name}', '{description}', '{number_of_beds}', '{floor}', '{building}', '{director_id}');\n")


def assign_to_department(fdr, table, amka):
    fdr.write(f"INSERT INTO {table}_dept (AMKA, dept_name) VALUES ('{amka}', '{random.choice(departments)}');\n")

# ========================================================================
#                               Room Gen 
# ========================================================================
room_ids = []

def generate_bed(fdr):
    room_id = room_ids[len(room_ids)-1] + 1
    roomd_ids.append(room_id)
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
    room_id = random.choice(room_id_beds)

    fdr.write(f"INSERT INTO bed (type, status, dept_name, room_id) VALUES ('{type_t}', '{status}', '{dept_name}', '{room_id}');\n")


# ========================================================================
#                               Bed Gen 
# ========================================================================

def generate_equipment(fdr):
    uid = fake.uuid4()
    description = fake.text(max_nb_chars=200)
    room_id = random.choice(room_ids)
    dept_name = random.choice(departments)

    fdr.write(f"INSERT INTO equipment (UID, description, room_id, dept_name) VALUES ('{uid}', '{description}', '{room_id}', '{dept_name}');\n")

def main():
    patient_num = 200;
    doctor_num = 80;
    nurse_num = 100;
    admin_num = 50;

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



        fdr.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        fdr.close()

if __name__ == "__main__":
    main()
