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
