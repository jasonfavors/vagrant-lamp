#!/bin/bash

##  Installs rails.

yum -y install centos-release-scl
yum -y install rh-ruby24
yum -y install rh-ruby24-ruby-devel
yum -y install gcc
yum -y install zlib-devel
yum -y install patch