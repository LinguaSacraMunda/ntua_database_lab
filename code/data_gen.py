import random
from datetime import datetime, timedelta
from faker import Faker

departments = ["Casualty", "Operating theatre (OT)", "Intensive care unit (ICU)", "Anesthesiology", "Cardiology", "ENT", "Geriatric", "Gastroenterology", "General surgery", "Gynaecology", "Haematology", "Pediatrics", "Neurology", "Oncology", "Opthalmology", "Orthopaedic", "Urology", "Psychiatry", "Inpatient Department (IPD)", "Outpatient Department (OPD)"]

fake = Faker('el_GR')

# ====================================
#             General data
# ====================================
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

    if end > datetime.now():
        end = datetime.now();

    return start + timedelta(days=random.randint(0, (end-start).days))

# ====================================
#            Patient Gen 
# ====================================
def generate_patient(fdr, triage_id):
    dob = random_date();
    amka = generate_amka(dob);

    first_name = fake.first_name()
    if random.random() < 0.2:
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

# ====================================
#            Nurse Gen 
# ====================================
def generate_nurse():
    dob = random_date()
    doe = generate_employment_date(dob)
    amka = generate_amka(dob)

    first_name = fake.first_name()
    if random.random() < 0.2:
        middle_name = fake.first_name
    else:
        middle_name = None 
    last_name = fake.last_name()

    rank = random.choice(['Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος'])


def main():
    patient_num = 200;
    doctor_num = 80;
    nurse_num = 100;
    admin_num = 50;

    with open("insert.sql", "w") as fdr:
        for i in range(patient_num):
            triage_id = generate_triage(fdr)
            amka = generate_patient(fdr, triage_id)
            generate_contacts(fdr, "patient", amka)

        fdr.close()

if __name__ == "__main__":
    main()
