#!/bin/bash

# System update
echo "Updating server.  This can take a while..."
yum -y update

echo "Setting up web server"
yum -y install httpd
service httpd start
chkconfig httpd on

groupadd www
chown -R root:www /var/www
chmod 2755 /var/www
find /var/www -type d -exec chmod 2755 {} \;
find /var/www -type f -exec chmod 0644 {} \;

echo "Securing web server"
yum -y install mod_ssl
sed -i -e 's/SSLProtocol all -SSLv2$/SSLProtocol -SSLv2 -SSLv3 \+TLSv1 \+TLSv1.1 \+TLSv1.2/g' /etc/httpd/conf.d/ssl.conf
sed -i -e 's/SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5:!SEED:!IDEA$/SSLCipherSuite ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA/g' /etc/httpd/conf.d/ssl.conf
sed -i -e 's/#SSLHonorCipherOrder on $/SSLHonorCipherOrder on/g' /etc/httpd/conf.d/ssl.conf
sed -i -e 's/#ServerName www.example.com:443$/ServerName 192.168.33.10:443/g' /etc/httpd/conf.d/ssl.conf

echo "Setting up database server"
yum -y install mariadb-server
service mariadb start
chkconfig mariadb on

echo "Securing database server"
. /vagrant/.provision/secrets/secrets.cfg
mysqladmin -u root password "$DB_PASSWORD"
mysql -u root -p"$DB_PASSWORD" -e "UPDATE mysql.user SET Password=PASSWORD('$DB_PASSWORD') WHERE User='root'"
mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DB_PASSWORD" -e "FLUSH PRIVILEGES"

echo "Setting up PHP"
yum -y install php php-mysql

echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
service httpd restart

echo "Setting up admin tools"
# Enable Extra Packages for Enterprise Linux (EPEL)
# yum-config-manager --enable epel

# phpMyAdmin
# yum install -y phpMyAdmin

echo "Setting up projects"
cp /vagrant/.provision/apache/000-default.conf /etc/httpd/conf.d/

# Example.com
mkdir -p /var/www/example.com
mkdir -p /etc/httpd/logs/example.com
cp /vagrant/.provision/apache/example.com.conf /etc/httpd/conf.d/
cp -R /vagrant/html /var/www/example.com

answers() {
	echo --
	echo SomeState
	echo SomeCity
	echo SomeOrganization
	echo SomeOrganizationalUnit
	echo example.com
	echo root@example.com
}

answers | openssl req -newkey rsa:2048 -keyout /etc/pki/tls/private/example.com.key -nodes -x509 -days 365 -out /etc/pki/tls/certs/example.com.crt 2> /dev/null

chown root:root /etc/pki/tls/private/example.com.key
chown root:root /etc/pki/tls/certs/example.com.crt
chmod 600 /etc/pki/tls/private/example.com.key
chmod 600 /etc/pki/tls/certs/example.com.crt
service httpd restart
