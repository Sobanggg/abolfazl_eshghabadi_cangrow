#!/bin/bash


#masir host ro behesh midim
HOSTS_FILE="/etc/hosts"

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


# Rane kardan docker-compose
docker compose up -d

# entezar baraye etminan az bala amadan tamam container ha
echo "Waiting for proxysql_cangrow container  running..."
while ! docker exec proxysql_cangrow /bin/bash -c "echo 'Proxysql is running'" &> /dev/null; do
    sleep 1
done


# Ejra kardan initial.sh dar container proxysql_cangrow
docker exec proxysql_cangrow /bin/bash /etc/proxysql/initial.sh

echo "service proxysql is runnig "
