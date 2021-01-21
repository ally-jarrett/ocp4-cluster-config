htpasswd -c htpasswd admin

cat userpasswords.csv | while read line; do 
	USERNAME=$(echo $line | awk -F ',' '{print $1}');
	PASSWORD=$(echo $line | awk -F ',' '{print $2}');
	echo $PASSWORD | htpasswd -i ./htpasswd $USERNAME;
	done;
