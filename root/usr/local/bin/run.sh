#!/bin/bash

cd /var/www/html/ || exit
PATH=$PATH:/usr/local/bin

server_name="${SERVER_NAME:-localhost}"
url="${URL:-http://localhost:8081}"
title="${TITLE:-"WordPress-Sample-Title"}"
admin_name="${ADMIN_NAME:-admin}"
admin_password="${ADMIN_PASSWORD:-admin}"
admin_email="${ADMIN_EMAIL:-admin@domain.com}"
plugins="${PLUGINS:-}"

# Initialize first run
if [[ -e /.firstrun ]]; then
    echo "First run detected, initializing WordPress..."
    init.sh apache2
    echo "Copying /content to /var/www/html/wp-content"
    cp -r /content/* /var/www/html/wp-content/
    echo "Initializing wp with admin information"
    wp core install --url=${url} --title=${title} --admin_name=${admin_name} --admin_password=${admin_password} --admin_email=${admin_email} --allow-root
    if [[ -n "$plugins" ]]; then
        for plugin in $plugins; do
            echo "Installing plugin \"$plugin\"..."
            wp plugin install $plugin --activate --allow-root
        done
    fi
    chown www-data:www-data /var/www/html/wp-content -R
    echo "ServerName ${server_name}" >> /etc/apache2/apache2.conf
fi

echo "Starting Apache..."
apache2-foreground