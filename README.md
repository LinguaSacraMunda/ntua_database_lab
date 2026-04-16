# ntua_db_2026 - Hospital database

## ECE, NTUA 6th semester Databases

This project aims to emulate a database for a Greek hospital. Created for the class "Databases", of the ECE department of NTUA, during the academic year 2025-2026, it utilises MySQL to build the database schema and apply relevant constraints.

# Installation

1. Clone the repository and navigate to the base directory
```
git clone https://github.com/LinguaSacraMunda/ntua_database_lab.git
cd ntua_database_lab
```

2. Load the schema and data
```
mysql -u root -p ntua_db_2026 < sql/install.sql
mysql -u root -p ntua_db_2026 < sql/load.sql
```
