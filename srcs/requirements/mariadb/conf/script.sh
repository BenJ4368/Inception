#!/bin/bash

echo "MARIADB SCRIPT ==================================="

echo "CREATE DATABASE IF NOT EXISTS $WP_DB_NAME ;" > /etc/mysql/init.sql
echo "CREATE USER IF NOT EXISTS '$WP_DB_USER'@'%' IDENTIFIED BY '$WP_DB_PASSWORD' ;" >> /etc/mysql/init.sql
echo "GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'%' ;" >> /etc/mysql/init.sql
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' ;" >> /etc/mysql/init.sql
echo "FLUSH PRIVILEGES;" >> /etc/mysql/init.sql

echo "/etc/mysql/init.sql contains :"
cat /etc/mysql/init.sql

mysql_install_db
mysqld
