#!/bin/bash

sleep 10


mysql -u admin -padmin -h 127.0.0.1 -P 6032 --execute="
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (10, 'master_cangrow', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (20, 'replica_cangrow', 3306);
INSERT INTO mysql_users(username, password, default_hostgroup) VALUES ('cangrow', '123', 10);
INSERT INTO mysql_users(username, password, active, use_ssl, default_hostgroup, max_connections) VALUES ('monitor', 'monitor', 1, 0, 10, 10000);
INSERT INTO mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup, apply) VALUES (100, 1, '^SELECT', 20, 1);
INSERT INTO mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup, apply) VALUES (200, 1, '^INSERT|^UPDATE|^DELETE', 10, 1);
LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;
LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;
LOAD MYSQL QUERY RULES TO RUNTIME; SAVE MYSQL QUERY RULES TO DISK;
"

echo "confing proxysql complete"

