

CHANGE MASTER TO
  MASTER_HOST='master_cangrow',
  MASTER_USER='rep_cangrow',
  MASTER_PASSWORD='cangrow',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=328;



START SLAVE;
FLUSH PRIVILEGES;


SHOW SLAVE STATUS\G
