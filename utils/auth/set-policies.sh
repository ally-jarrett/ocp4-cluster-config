cat users.csv | while read line; do USERNAME=$(echo $line | awk -F ',' '{print $1}'); if [[ $line == *"redhat"* ]]; then oc adm policy add-cluster-role-to-user admin $USERNAME; else oc adm policy add-cluster-role-to-user edit $USERNAME; fi; done;
oc adm policy add-cluster-role-to-user admin admin
