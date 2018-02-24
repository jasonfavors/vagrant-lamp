#!/bin/bash
#
# mysql          Installs and configures MySQL Server
#

echo "Installing MySQL Server"

yum -y install centos-release-scl
yum -y install rh-mysql57-mysql

echo "Starting database server"

systemctl start rh-mysql57-mysqld.service
systemctl enable rh-mysql57-mysqld.service

echo "Securing database server"
scl enable rh-mysql57 -- mysqladmin -u root password "$DB_PASSWORD"
scl enable rh-mysql57 -- mysql -u root -p"$DB_PASSWORD" -e "UPDATE mysql.user SET Password=PASSWORD('$DB_PASSWORD') WHERE User='root'"
scl enable rh-mysql57 -- mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
scl enable rh-mysql57 -- mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''"
scl enable rh-mysql57 -- mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
scl enable rh-mysql57 -- mysql -u root -p"$DB_PASSWORD" -e "FLUSH PRIVILEGES"
