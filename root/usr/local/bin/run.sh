#!/bin/bash
set -euo pipefail

# Apache run script for nitro.
# WordPress initialization is performed here so MariaDB service can start first.

if [ -e /.firstrun ]; then
	echo "First run detected, initializing WordPress at runtime..."

	cd /var/www/html/
	export PATH="$PATH:/usr/local/bin"

	: "${WORDPRESS_DB_HOST:=127.0.0.1}"
	: "${WORDPRESS_DB_NAME:=wordpress}"
	: "${WORDPRESS_DB_USER:=wordpress}"
	: "${WORDPRESS_DB_PASSWORD:=wordpress}"
	export WORDPRESS_DB_HOST WORDPRESS_DB_NAME WORDPRESS_DB_USER WORDPRESS_DB_PASSWORD

	db_name_escaped="$(printf "%s" "$WORDPRESS_DB_NAME" | sed "s/'/''/g")"
	db_user_escaped="$(printf "%s" "$WORDPRESS_DB_USER" | sed "s/'/''/g")"
	db_pass_escaped="$(printf "%s" "$WORDPRESS_DB_PASSWORD" | sed "s/'/''/g")"

	echo "Waiting for MariaDB before DB bootstrap..."
	max_mariadb_wait_cycles="${MARIADB_WAIT_CYCLES:-90}"
	mariadb_wait_cycles=0
	until mariadb-admin ping >/dev/null 2>&1; do
		echo "MariaDB is still starting up... sleeping"
		sleep 2
		mariadb_wait_cycles=$((mariadb_wait_cycles + 1))
		if [ "$mariadb_wait_cycles" -ge "$max_mariadb_wait_cycles" ]; then
			echo "ERROR: MariaDB did not become ready for DB bootstrap" >&2
			exit 1
		fi
	done

	echo "Bootstrapping MariaDB database and user..."
	mariadb -uroot <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${db_name_escaped}\`;
CREATE USER IF NOT EXISTS '${db_user_escaped}'@'localhost' IDENTIFIED BY '${db_pass_escaped}';
CREATE USER IF NOT EXISTS '${db_user_escaped}'@'127.0.0.1' IDENTIFIED BY '${db_pass_escaped}';
GRANT ALL PRIVILEGES ON \
	\`${db_name_escaped}\`.* TO '${db_user_escaped}'@'localhost';
GRANT ALL PRIVILEGES ON \
	\`${db_name_escaped}\`.* TO '${db_user_escaped}'@'127.0.0.1';
FLUSH PRIVILEGES;
EOSQL

	/usr/local/bin/init.sh apache2

	url="${URL:-http://localhost:8081}"
	title="${TITLE:-WordPress-Sample-Title}"
	admin_name="${ADMIN_NAME:-admin}"
	admin_password="${ADMIN_PASSWORD:-admin}"
	admin_email="${ADMIN_EMAIL:-admin@domain.com}"

	if ! su -s /bin/bash -c "wp core is-installed" www-data >/dev/null 2>&1; then
		echo "Installing WordPress core..."
		su -s /bin/bash -c "wp core install --url='${url}' --title='${title}' --admin_name='${admin_name}' --admin_password='${admin_password}' --admin_email='${admin_email}'" www-data
	else
		echo "WordPress is already installed; skipping core install."
	fi

	plugins="${PLUGINS:-}"
	if [[ -n "$plugins" ]]; then
		for plugin in $plugins; do
			echo "Installing plugin '$plugin'..."
			su -s /bin/bash -c "wp plugin install '$plugin' --activate" www-data
		done
	fi

	chown -R www-data:www-data /var/www/html/wp-content

	server_name="${SERVER_NAME:-localhost}"
	if ! grep -q "^ServerName ${server_name}$" /etc/apache2/apache2.conf; then
		echo "ServerName ${server_name}" >> /etc/apache2/apache2.conf
	fi

	rm -f /.firstrun
	echo "First-run initialization complete."
fi

echo "Starting Apache..."
exec apache2-foreground