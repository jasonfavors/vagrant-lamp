#!/bin/bash
#
# yum            Update server
#

# System update
echo "Updating server.  This can take a while..."
yum -y update

# Add Software Collection Library (SCL) repo
yum -y install centos-release-scl

# Enable Extra Packages for Enterprise Linux (EPEL)
yum -y install epel-release
