#!/bin/bash

##  Installs rails.

yum -y install rh-ruby24 rh-ruby24-ruby-devel \
               httpd24-httpd-devel httpd24-libcurl-devel \
               openssl-devel gcc gcc-c++ zlib-devel sqlite-devel \

# Install NodeJS for JavaScript runtime
yum -y install nodejs npm --enablerepo=epel

scl enable rh-ruby24 -- gem install bundler --no-document
scl enable rh-ruby24 -- gem install rails --no-document
scl enable rh-ruby24 -- gem install passenger --no-document

passenger_root=$(scl enable rh-ruby24 -- passenger-config --root)
passenger_ruby=$(scl enable rh-ruby24 -- passenger-config --ruby-command |\
                 sed -n 's/  Command: //p' | head -n 1)
echo "# This configuration file loads the Passenger module built from the
# Passenger gem.

LoadModule passenger_module $passenger_root/buildout/apache2/mod_passenger.so
" > /opt/rh/httpd24/root/etc/httpd/conf.modules.d/02-passenger.conf

echo "#
# This configuration file sets the default Passenger directives for
# this server.
#

<IfModule mod_passenger.c>
 PassengerRoot $passenger_root
 PassengerDefaultRuby $passenger_ruby
</IfModule>" > /opt/rh/httpd24/root/etc/httpd/conf.d/passenger.conf

# Build Passenger modules
scl enable httpd24 rh-ruby24 -- passenger-install-apache2-module \
                                --language ruby --auto
