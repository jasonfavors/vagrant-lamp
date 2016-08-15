#!/bin/bash
echo "Updating package repos..."
apt-get update -qq
apt-get install git puppet -y

echo "Fetching puppet configurations..."
mv /etc/puppet /etc/puppet.orig
git clone $puppet_source /etc/puppet

echo "Applying puppet configurations..."
puppet apply /etc/puppet/manifests/init.pp
