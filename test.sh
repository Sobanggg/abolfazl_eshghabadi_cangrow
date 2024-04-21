#!/bin/bash

#masir host ro behesh midim
HOSTS_FILE="/etc/hosts"

while true; do
    source .env
    clear
    echo -e "1.start cangrow-web \n2.stop cangrow-web \n3.WordPress user authentication \n4.clear cangrow-web \n5.help \n6.exit"
    read -p "select the option:  " VAR1
    VAR1=$(echo $VAR1 | tr -d [:alpha:] | tr -d [:blank:])

    case $VAR1 in
        1)
            clear
            docker compose up -d
            if [ "$startup_config" == "0" ]; then
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
        echo -e "1:started and run startup config for cangrow-web \n2.stopped cangrow web and not remove data \n3.WordPress user authentication for To access the dashboard wordpress \n4.remove all volume and data for cangrow-web \n\n"
        echo "Press Enter to continue..."
        read -p ""
        ;;
        6)
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

