#!/bin/bash

# Source Configurations
. /vagrant/.provision/secrets/secrets.cfg

su -- $web_user

cd /home/$web_user

# Enable WP-CLI completion
curl - O https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash
echo "source ~/wp-completion.bash" >> ~/.bashrc
