-- تنظیم server_id که باید منحصر به فرد باشد
SET @@GLOBAL.server_id = 2;

-- تنظیم مشخصات master
CHANGE MASTER TO
  MASTER_HOST='master_cangrow',
  MASTER_USER='replication_user',
  MASTER_PASSWORD='123',
  MASTER_LOG_FILE='mysql-bin.000007',
  MASTER_LOG_POS=328;

-- شروع replication
START SLAVE;

-- بررسی وضعیت replication
SHOW SLAVE STATUS\G
