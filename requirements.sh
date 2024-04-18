#!/bin/bash
source .env

#masir host ro behesh midim
HOSTS_FILE="/etc/hosts"
while [ -z $VAR1 ]
do
clear
echo -e "1.start cangrow-web \n2.stop cangrow-web \n3.WordPress user authentication \n4.clear cangrow-web"
read -p "select the option:  " VAR1
VAR1=`echo $VAR1 | tr -d [:alpha:] | tr -d [:blank:]`
done

if [ "$VAR1" == "1" ]; then
clear

# Rane kardan docker-compose
docker compose up -d



if [ "$startup_config" == "0" ]; then
    # entezar baraye etminan az bala amadan tamam container ha
echo "Waiting for proxysql_cangrow container  running..."
while ! docker exec proxysql_cangrow /bin/bash -c "echo 'Proxysql is running'" &> /dev/null; do
    sleep 1
done


# Ejra kardan initial.sh dar container proxysql_cangrow
docker exec proxysql_cangrow /bin/bash /etc/proxysql/initial.sh
    
#yek araye az service ha tarif mikonim
declare -A services=(
    [master_cangrow]="172.28.0.2"
    [replica_cangrow]="172.28.0.3"
    [wordpress1_cangrow]="172.28.0.4"
    [wordpress2_cangrow]="172.28.0.5"
    [nginx_cangrow]="172.28.0.6"
    [proxysql_cangrow]="172.28.0.7"
)
#add kardan ip ha be hosts va agar tekrari nabod
for service in "${!services[@]}"; do
    if ! grep -q "${services[$service]} $service" "$HOSTS_FILE"; then
        echo "${services[$service]} $service" | sudo tee -a "$HOSTS_FILE" > /dev/null
    fi
done

echo "all ips added to $HOSTS_FILE "


    echo "startup config complete"
    
    sed -i 's/startup_config=0/startup_config=1/' .env
else
    echo "startup config are available"
fi




echo "cangrow-web runnig... "

elif [ "$VAR1" == "2" ];then
clear
docker compose down
echo "cangrow-web stop..."

elif [ "$VAR1" == "3" ];then
clear
  mysql -u root -h master_cangrow -p$MYSQL_ROOT_PASSWORD -e "
    USE $MYSQL_DATABASE;
    INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES (1, 'wp_capabilities', 'a:1:{s:13:\"administrator\";b:1;}');
    INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES (1, 'wp_user_level', '10');
    "

echo "You have access to make changes:)"

elif [ "$VAR1" == "4" ];then
 clear
 
    echo "remove all volumes?(all volums removed!) "
    read -p "yes OR no: " confirmation
    confirmation=`echo $confirmation | tr '[:upper:]' '[:lower:]'`
    if [ "$confirmation" == "yes" ]; then
    docker compose down
echo "cangrow-web stopped"
        docker volume rm wordpress_data
        docker volume rm proxysql_data
        docker volume rm mariadb_master_data
        docker volume rm mariadb_replica_data
        echo "All volumes removed."
    else
        echo "Volume removal cancelled."
    fi
fi
