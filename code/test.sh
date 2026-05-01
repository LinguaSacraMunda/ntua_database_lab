#!/bin/bash

for i in $(seq -w 1 15)
do
    echo "Q${i} START"
    if [ ! -f "../sql/Q${i}_out.txt" ]; then
        touch "../sql/Q${i}_out.txt"
    fi

    mariadb -u root -pabaeterno ntua_db_2026 -t < "../sql/Q${i}.sql" > "../sql/Q${i}_out.txt"
    echo "Q${i} END"
done
