-- تنظیم server_id که باید منحصر به فرد باشد
SET @@GLOBAL.server_id = 1;

-- فعال کردن binary logging با مشخص کردن مسیر و نام فایل
SET @@GLOBAL.log_bin = '/var/lib/mysql/mariadb-bin';

-- مشخص کردن دیتابیس‌هایی که باید تغییرات آن‌ها ثبت شود
SET @@GLOBAL.binlog_do_db = 'wordpress';

-- تنظیم فرمت باینری لاگ
SET @@GLOBAL.binlog_format = 'mixed';

-- ایجاد کاربر replication با دسترسی‌های لازم
CREATE USER 'replication_user'@'%' IDENTIFIED BY '123';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';

-- نمایش وضعیت master برای استفاده در slave
SHOW MASTER STATUS;

