cat users.csv | while read line; do HELLO=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16}; echo); echo ${line},$HELLO >> userpasswords.csv; done;

