#!/bin/bash

# nginx
echo "Setting up Nginx"
apt-get install nginx -y
service nginx start

# set up nginx server
cp /vagrant/.provision/nginx/nginx.conf /etc/nginx/sites-available/site.conf
chmod 644 /etc/nginx/sites-available/site.conf
ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
service nginx restart

# clean /var/www
sudo rm -Rf /var/www

# symlink /var/www => /vagrant
ln -s /vagrant /var/www
