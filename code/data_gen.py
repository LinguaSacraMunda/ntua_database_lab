import random
from datetime import datetime, timedelta
from faker import Faker

departments = ["Casualty", "Operating theatre (OT)", "Intensive care unit (ICU)", "Anesthesiology", "Cardiology", "ENT", "Geriatric", "Gastroenterology", "General surgery", "Gynaecology", "Haematology", "Pediatrics", "Neurology", "Oncology", "Opthalmology", "Orthopaedic", "Urology", "Psychiatry", "Inpatient Department (IPD)", "Outpatient Department (OPD)"]
deps_without_director = departments
patient_ids = []
nurse_ids = []
admin_ids = []
doctor_ids = []
doctor_dir = []
doctor_senior = []

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
    fdr.write(f"INSERT INTO triage (level, symptoms) VALUES ({level}, '{symptoms}');\n")

def generate_contacts(fdr, table, amka):
    for i in range(random.randint(1,2)):
        fdr.write(f"INSERT INTO {table}_email (AMKA, phone_number) VALUES ({amka}, '{fake.email()}');\n")


    for i in range(random.randint(1,3)):
        fdr.write(f"INSERT INTO {table}_phone (AMKA, phone_number) VALUES ({amka}, '{fake.phone_number()}');\n")


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

    fdr.write(f"INSERT INTO patient (AMKA, first_name, middle_name, last_name, date_of_birth, sex, weight, height, street_name, street_number, postal_code, area, municipality, prefecture,  profession, citizenship, triage_id) VALUES ({amka},'{first_name}',{middle_name},'{last_name}',{dob.date()},{sex},{weight},{height},'{street_name}',{street_number},'{postal_code}','{area}','{municipality}','{prefecture}','{profession}','{citizenship}',{triage_id});\n")
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

    fdr.write(f"INSERT INTO nurse (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, rank, dept_name) VALUES ({amka}, '{first_name}', '{middle_name}', '{last_name}', '{dob.date()}', '{doe.date()}', '{rank}', '{dept_name}');\n")

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

    fdr.write(f"INSERT INTO administrative_staff (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, role, office, dept_name) VALUES ({amka}, '{first_name}', '{middle_name}', '{last_name}', '{dob.date()}', '{doe.date()}', '{role}', '{office}', '{dept_name}');\n")

# ========================================================================
#                             Doctor Gen 
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
    if (rank != 'Ειδικευόμενος'):
        doctor_senior.append(amka)
    if (rank == 'Διευθυντής'):
        doctor_dir.append(amka)

    license_num = f"{random.randint(0, 9999999999):010d}"

    fdr.write(f"INSERT INTO doctor (AMKA, first_name, middle_name, last_name, date_of_birth, date_of_employment, license_number, rank) VALUES ({amka}, '{first_name}', '{middle_name}', '{last_name}', '{dob.date()}', '{doe.date()}', '{license_num}', '{rank}');\n")

def generate_supervision(fdr, amka):
    super = random.choice(doctor_senior)
    fdr.write(f"UPDATE doctor SET supervisor_id = '{super}' WHERE AMKA = {amka}")

def main():
    patient_num = 200;
    doctor_num = 80;
    nurse_num = 100;
    admin_num = 50;

    with open("insert.sql", "w") as fdr:
        fdr.write("SET FOREIGN_KEY_CHECKS = 0;\n")

        for i in range(patient_num):
            triage_id = generate_triage(fdr)
            amka = generate_patient(fdr, triage_id)
            generate_contacts(fdr, "patient", amka)

        for i in range(nurse_num):
            amka = generate_nurse(fdr)
            generate_contacts(fdr, "nurse", amka)

        for i in range(admin_num):
            amka = generate_admin(fdr)
            generate_contacts(fdr, "admin", amka)

        for i in range(doctor_num):
            amka = generate_doctor(fdr)
            generate_contacts(fdr, "doctor", amka)

        for i in list(set(doctor_ids) - set(doctor_dir)):
            if (random.random() < 0.7):
                generate_supervision(fdr, i)



        fdr.write("SET FOREIGN_KEY_CHECKS = 1;\n")
        fdr.close()

if __name__ == "__main__":
    main()
