#!/bin/bash
#
# php            Installs and configures PHP
#

echo "Setting up PHP"
yum -y install php php-mysql

echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
