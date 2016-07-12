#!/bin/bash
echo "Updating installed packages.  This could take a while..."
apt-get update
apt-get upgrade -y

echo "Installing Apache..."
apt-get install apache2

echo "Installing MySQL..."
apt-get install mysql-server libapache2-mod-auth-mysql php-mysql
mysql_install_db
mysql_secure_installation -y

echo "Installing PHP..."
apt-get install php5 libapache2-mod-php5 php5-mcrypt

echo "Starting web server..."
service httpd start
chkconfig httpd on
groupadd www
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
