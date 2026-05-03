#!/bin/bash

act=$(systemctl -q is-active mysql && echo 1 || echo 0)
if [ $act -eq 0 ]; then
    echo "mysql/mariadb inactive"
    exit 1
fi

for i in $(seq -w 1 15)
do
    echo "Q${i} START"
    if [ ! -f "sql/Q${i}_out.txt" ]; then
        touch "sql/Q${i}_out.txt"
    fi

    mariadb -u root -p$1 ntua_db_2026 -t < "sql/Q${i}.sql" > "sql/Q${i}_out.txt"
    echo "Q${i} END"
done

unset pas
