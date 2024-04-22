#!/bin/bash

#masir host ro behesh midim
HOSTS_FILE="/etc/hosts"

while true; do
    source .env
    clear
    echo -e "1.start cangrow-web \n2.stop cangrow-web \n3.WordPress user authentication \n4.clear cangrow-web \n5.show wordpress path \n6.show replica status \n7.show master status \n8.show proxysql status \n9.help \n10.exit"
    read -p "select the option:  " VAR1
    VAR1=$(echo $VAR1 | tr -d [:alpha:] | tr -d [:blank:])

    case $VAR1 in
        1)
            clear
            if [ "$startup_config" == "0" ]; then
                echo "installing docker "
                sudo apt-get update
                sudo apt-get install ca-certificates curl
                sudo install -m 0755 -d /etc/apt/keyrings
                sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                sudo chmod a+r /etc/apt/keyrings/docker.asc
                echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update
                sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

                # اجرای تست hello-world
                if sudo docker run hello-world; then
                    echo "Docker installed and tested successfully."
                else
                    echo "error installing docker "
                    read -p ""
                    exit 1
                fi
                 sudo apt-get install docker-compose

                # Docker Compose
                if docker-compose --version; then
                    echo "Docker Compose  installed successfully."
                else
                    echo "error installing docker compose"
                    read -p ""
                    exit 1
                fi
                # نصب MySQL Client
                sudo apt-get install mysql-client

                # تست نصب MySQL Client
                if mysql --version; then
                    echo "MySQL Client has been installed successfully."
                else
                    echo "There was an issue installing MySQL Client."
                    read -p ""
                    exit 1
                fi
                LINE='debian ALL=(ALL) NOPASSWD:ALL'

                # add sudo permission
                if sudo grep -Fxq "$LINE" /etc/sudoers; then
                    echo "There has been permission"
                else
                    echo "permission sudo add"
                    echo "$LINE" | sudo EDITOR='tee -a' visudo
                fi

                        docker compose up -d

                echo "Waiting for proxysql_cangrow container running..."
                while ! docker exec proxysql_cangrow /bin/bash -c "echo 'Proxysql is running'" &> /dev/null; do
                    sleep 1
                done
                docker exec proxysql_cangrow /bin/bash /etc/proxysql/initial.sh
                declare -A services=(
                    [master_cangrow]="172.28.0.2"
                    [replica_cangrow]="172.28.0.3"
                    [wordpress1_cangrow]="172.28.0.4"
                    [wordpress2_cangrow]="172.28.0.5"
                    [nginx_cangrow]="172.28.0.6"
                    [proxysql_cangrow]="172.28.0.7"
                )
                for service in "${!services[@]}"; do
                    if ! grep -q "${services[$service]} $service" "$HOSTS_FILE"; then
                        echo "${services[$service]} $service" | sudo tee -a "$HOSTS_FILE" > /dev/null
                    fi
                done
                echo "all ips added to $HOSTS_FILE"
                echo "startup config complete"
                sed -i 's/startup_config=0/startup_config=1/' .env
            else
                echo "startup config are available"
            fi
	    docker compose up -d 
            echo "cangrow-web running..."
             echo "Press Enter to continue..."
            read -p ""
            ;;
        2)
            clear
            docker compose down
            echo "cangrow-web stopped..."
             echo "Press Enter to continue..."
            read -p ""
            ;;
        3)
            clear
            mysql -u root -h master_cangrow -p$MYSQL_ROOT_PASSWORD -e "
                USE $MYSQL_DATABASE;
                INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES (1, 'wp_capabilities', 'a:1:{s:13:\"administrator\";b:1;}');
                INSERT INTO wp_usermeta (user_id, meta_key, meta_value) VALUES (1, 'wp_user_level', '10');
                "
            echo "You have access to make changes:)"
             echo "Press Enter to continue..."
             read -p ""
            ;;
        4)
            clear
            echo "remove all volumes?(all volumes removed!) "
            read -p "yes OR no: " confirmation
            confirmation=$(echo $confirmation | tr '[:upper:]' '[:lower:]')
            if [ "$confirmation" == "yes" ]; then
                docker compose down
                echo "cangrow-web stopped"
                docker volume rm wordpress_data
                docker volume rm proxysql_data
                docker volume rm mariadb_master_data
                docker volume rm mariadb_replica_data
                sed -i 's/startup_config=1/startup_config=0/' .env

                echo "All volumes removed."
            else
                echo "Volume removal cancelled."
            fi
            echo "Press Enter to continue..."
            read -p ""
            ;;
        5)
           clear
            echo `docker volume inspect wordpress_data | awk '/Mountpoint/ {print $2}' | sed 's/[",]//g'`
           read -p ""
            ;;


     
        6)
        clear 
        mysql -u root -h replica_cangrow -p123 -e "SHOW SLAVE STATUS\G"
        read -p ""
        ;;



        7)
         clear 
        mysql -u root -h master_cangrow -p123 -e "SHOW MASTER STATUS;"
        read -p ""
        ;;
     
        8)
         clear 
        docker exec -it proxysql_cangrow bash -c "
        mysql -u admin -padmin -h 127.0.0.1 -P 6032 --prompt='ProxySQLAdmin> ' -e '
        SELECT * FROM mysql_users;
        SELECT * FROM mysql_servers;
        '"
          read -p ""
        ;;

        9)
            clear
          echo -e "1:started and run startup config for cangrow-web \n2.stopped cangrow web and not remove data \n3.WordPress user authentication for To access the dashboard wordpress \n4.remove all volume and data for cangrow-web \n5.show path volume wordpress \n6.show status connection in replica db \n7.show status connection in master db \n8.show status connection in proxysql \nuserWordpress:admin password:@cangrow#\n\n"
          echo "Press Enter to continue..."
          read -p ""
          ;;

        10)
            echo "Good luck ..."
            sleep 2
            clear
            break
            ;;
        

        *)
            echo "Invalid option, please try again."
            sleep 1
            ;;
    esac
done

