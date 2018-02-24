# vagrant-lamp
An initial LAMP stack for Vagrant.

## Overview
Provisions a base Linux VM to run an Apache web server and MySQL database server, with PHP support.  Uses the following:

* CentOS 7
* Apache 2.4
* MariaDB 5.5
* PHP 5.4.16

## Requirements
* [VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://www.vagrantup.com)

## Getting Started
1. Make a `secrets.cfg` file:

  ```shell
  $ cp .provision/secrets/secerts.cfg.example .provision/secrets/secrets.cfg
  ```
1. Update `secrets.cfg` with a root *`DB_PASSWORD`*.
1. Spin up the VM:

  ```shell
  $ vagrant up
  $ vagrant ssh
  ```

## Features

### Multiple Virtual Hosts
Two virtual hosts are included at startup as an example of how Apache can server multiple hosts with the same instance.

 * http://192.168.33.10
 * http://example.com

### SSL Enabled by Default
SSL is enabled by default.  The bootstrap script follows recommendations from [Configure Apache Web Server on Amazon Linux to use SSL/TLS](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-an-instance.html) to make the server more secure.

Use HTTPS with the initial sites for secure traffic.

### Additional Tools
1. phpMyAdmin
1. WP-CLI

## Notes

### Apache PHP Info
https://192.168.33.10/phpinfo.php is active by default to demonstrate PHP being properly installed.

After verifying, you may want to remove this file (`/var/www/html/phpinfo.php`) for security reasons.

### Accessing Named Hosts from Your Local Browser
This setup adds `example.com` as a virtual host.  Edit your local `hosts` file to point this domain to your VM's IP:

```
# Vagrant Domains
192.168.33.10  example.com
```

Set up additional virtual hosts in `/etc/httpd/conf.d/`, a la `example.com.conf`.
