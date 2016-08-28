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
