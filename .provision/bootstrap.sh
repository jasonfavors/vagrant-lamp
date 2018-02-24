#!/bin/bash

# Source Configurations
. /vagrant/.provision/secrets/secrets.cfg


# yum -y install rh-ruby24
# yum -y install wget
/vagrant/.provision/scripts/yum.sh
/vagrant/.provision/scripts/apache.sh
/vagrant/.provision/scripts/php.sh
/vagrant/.provision/scripts/mysql.sh

echo "Starting web server"

systemctl start httpd24-httpd.service
systemctl enable httpd24-httpd.service


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
