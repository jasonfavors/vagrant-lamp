#!/bin/bash
#
# apache         Installs and configures Apache HTTP Web Server
#

echo "Installing Apache HTTP Server"

yum -y install centos-release-scl
yum -y install httpd24

echo "Setting up web server"

ip_address=$(hostname -I | cut -d " " -f 2)

cp -v /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf{,.orig}
sed -i -e "s/#ServerName www.example.com:80$/ServerName $ip_address:80/g" /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf
diff /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf{.orig,}

groupadd www
usermod -a -G www vagrant
usermod -a -G www apache
chown -vR root:www /opt/rh/httpd24/root/var/www
chmod -v 2775 /opt/rh/httpd24/root/var/www
find /opt/rh/httpd24/root/var/www -type d -exec chmod -v 2775 {} \;
find /opt/rh/httpd24/root/var/www -type f -exec chmod -v 0664 {} \;

echo "Securing web server"

yum -y install httpd24-mod_ssl

cp -v /opt/rh/httpd24/root/etc/httpd/conf.d/ssl.conf{,.orig}
sed -i -e 's/^SSLProtocol all -SSLv2$/SSLProtocol -SSLv2 -SSLv3 \+TLSv1 \+TLSv1.1 \+TLSv1.2/g' /opt/rh/httpd24/root/etc/httpd/conf.d/ssl.conf
sed -i -e 's/^SSLCipherSuite .*$/SSLCipherSuite ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA/g' /opt/rh/httpd24/root/etc/httpd/conf.d/ssl.conf
sed -i -e 's/#SSLHonorCipherOrder on $/SSLHonorCipherOrder on/g' /opt/rh/httpd24/root/etc/httpd/conf.d/ssl.conf
sed -i -e "s/#ServerName www.example.com:443$/ServerName $ip_address:443/g" /opt/rh/httpd24/root/etc/httpd/conf.d/ssl.conf
diff /opt/rh/httpd24/root/etc/httpd/conf.d/ssl.conf{.orig,}
