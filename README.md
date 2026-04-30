# ntua_db_2026 - Hospital database

## ECE, NTUA 6th semester Databases

This project aims to emulate a database for a Greek hospital. Created for the class "Databases", of the ECE department of NTUA, during the academic year 2025-2026, it utilises MySQL to build the database schema and apply relevant constraints.

# Installation

1. Clone the repository and navigate to the base directory
```
git clone https://github.com/LinguaSacraMunda/ntua_database_lab.git
cd ntua_database_lab
```

2. Load the schema and standard data
```
mysql -u root -p ntua_db_2026 < sql/install.sql
mysql -u root -p ntua_db_2026 < sql/load.sql
```

3. Generate dummy data (optional)
```
pip install -r code/requirements.txt
python code/data_gen.py
```

Note that the python script generating the above data is naive; complex constraints enforced by the database are not taken into account, simplifying the generation process. Therefore, a number of errors may be encountered when prompting the insertion, specifically when staging and enabling the shifts. These are expected and a product of the implemented triggers.
Additionally, not all queries Q01-Q15 are guaranteed to return a non-empty set, due to the randomness of the generated data.

3. Load dummy data
```
mysql -u root -p ntua_db_2026 < code/insert.sql
```
