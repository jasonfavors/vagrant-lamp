#!/bin/bash

# Source Configurations
. /vagrant/.provision/secrets/secrets.cfg

# Example.com
mkdir -p /var/www/example.com
mkdir -p /etc/httpd/logs/example.com
cp /vagrant/.provision/apache/example.com.conf /etc/httpd/conf.d/
chown -R $web_user:www /var/www/example.com
chmod 2755 /var/www/example.com

# Create SSL Certs
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

# Setup WP (under $web_user)
mysql -u root -p"$DB_PASSWORD" -e "CREATE DATABASE $WP_DB"
mysql -u root -p"$DB_PASSWORD" -e "CREATE USER $WP_DB_USER@$WP_DB_HOST"
mysql -u root -p"$DB_PASSWORD" -e "SET PASSWORD FOR $WP_DB_USER@$WP_DB_HOST= PASSWORD('$WP_DB_PASSWORD')"
mysql -u root -p"$DB_PASSWORD" -e "GRANT ALL PRIVILEGES ON $WP_DB.* TO $WP_DB_USER@$WP_DB_HOST IDENTIFIED BY '$WP_DB_PASSWORD'"
mysql -u root -p"$DB_PASSWORD" -e "FLUSH PRIVILEGES"

sudo -u $web_user -i -- /usr/local/bin/wp core download --path=/var/www/example.com/html
sudo -u $web_user -i -- /usr/local/bin/wp core config --path=/var/www/example.com/html --dbname=$WP_DB --dbuser=$WP_DB_USER --dbpass=$WP_DB_PASSWORD --dbhost=$WP_DB_HOST --dbprefix=$WP_DB_PREFIX --extra-php <<PHP
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);
define('WP_MEMORY_LIMIT', '256M');
define( 'AUTOSAVE_INTERVAL', 300 );
define( 'EMPTY_TRASH_DAYS', 7 );
define( 'DISALLOW_FILE_EDIT', true );
define( 'FORCE_SSL_ADMIN', true );
PHP
sudo -u $web_user -i -- /usr/local/bin/wp core install --path=/var/www/example.com/html --url=example.com --title=Example.com --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL

# Plugins
# sudo -u $web_user -i -- /usr/local/bin/wp plugin install X --path=/var/www/example.com/html

# Misc Cleanup
sudo -u $web_user -i -- /usr/local/bin/wp post delete 1 --path=/var/www/example.com/html
sudo -u $web_user -i -- /usr/local/bin/wp plugin delete hello --path=/var/www/example.com/html
sudo -u $web_user -i -- /usr/local/bin/wp rewrite structure "/%year%/%monthnum%/%day%/%postname%/" --path=/var/www/example.com/html
cat <<REWRITE > /var/www/example.com/html/.htaccess
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
REWRITE

sudo -u $web_user -i -- /usr/local/bin/wp rewrite flush --path=/var/www/example.com/html

service httpd restart
