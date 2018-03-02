echo "Setting up admin tools"

# phpMyAdmin
yum install -y phpMyAdmin
sed -i -e "s/127.0.0.1/$remote_ip_address/g" /etc/httpd/conf.d/phpMyAdmin.conf

# WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
