#!/bin/bash

# Configurations
web_user=vagrant
. /vagrant/.provision/secrets/secrets.cfg # DB_PASSWORD
remote_ip_address=192.168.33.1

# System update
echo "Updating server.  This can take a while..."
yum -y update

echo "Setting up web server"
yum -y install httpd
service httpd start
chkconfig httpd on

groupadd www
usermod -a -G www $web_user
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
yum install -y epel-release

# phpMyAdmin
yum install -y phpMyAdmin
sed -i -e "s/127.0.0.1/$remote_ip_address/g" /etc/httpd/conf.d/phpMyAdmin.conf

# WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

echo "Setting up projects"
cp /vagrant/.provision/apache/000-default.conf /etc/httpd/conf.d/
