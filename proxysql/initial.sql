-- initial.sql
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (10, '172.28.0.2', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (20, '172.28.0.3', 3306);
INSERT INTO mysql_users(username, password, default_hostgroup) VALUES ('cangrow', '123', 10);
INSERT INTO mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup, apply) VALUES (100, 1, '^SELECT', 20, 1);
INSERT INTO mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup, apply) VALUES (200, 1, '^INSERT|^UPDATE|^DELETE', 10, 1);
LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;
LOAD MYSQL USERS TO RUNTIME; SAVE MYSQL USERS TO DISK;
LOAD MYSQL QUERY RULES TO RUNTIME; SAVE MYSQL QUERY RULES TO DISK;
