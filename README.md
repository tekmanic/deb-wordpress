# deb-wordpress

A specialized Docker image providing a Debian Trixie-based WordPress environment with an internal MariaDB instance and automated plugin installation, powered by the Nitro init system.

## Overview
This repository is designed for creating WordPress sandbox environments. It allows you to run multiple isolated WordPress installations in parallel without conflicts, making it ideal for development and testing.

## Key Features
- **Modern Base:** Upgraded to Debian Trixie for the latest security and package updates.
- **Nitro Init System:** Powered by Nitro 0.8.1 for fast, lean, and reliable service management.
- **Integrated Database:** Includes an internal MariaDB server for zero-config startup.
- **Automated Setup:** Uses WP-CLI for automated site installation and plugin activation.
- **Persistent Content:** Supports Docker volumes for persisting themes, plugins, and uploads.
- **Security Hardened:** Implements PHP function restrictions and removes setuid/setgid bits to reduce attack surface.
- **Protected Environments:** Includes optional Basic Auth and IP restriction.

## Usage

To run a new instance:

```bash
docker run -d \
        --net="bridge" \
        --name=wordpress \
        -p 8081:80 \
        -e SERVER_NAME=localhost \
        -e URL="http://localhost:8081" \
        -e ADMIN_NAME=admin \
        -e ADMIN_PASSWORD=admin \
        -e ADMIN_EMAIL=admin@domain.com \
        -e PLUGINS='contact-form-7' \
        -e TITLE='Wordpress-Title' \
        -v wp-content:/content \
        -v wordpress-db:/var/lib/mysql \
        deb-wordpress:latest
```

### Configuration Environment Variables
| Variable | Description | Default |
|-----------|-------------|---------|
| `SERVER_NAME` | Apache ServerName | `localhost` |
| `URL` | WordPress Site URL | `http://localhost:8081` |
| `ADMIN_NAME` | WP Admin Username | `admin` |
| `ADMIN_PASSWORD` | WP Admin Password | `admin` |
| `ADMIN_EMAIL` | WP Admin Email | `admin@domain.com` |
| `PLUGINS` | Space-separated list of plugins to install | `` |
| `TITLE` | Site Title | `WordPress-Sample-Title` |
| `BASIC_AUTH_ENABLED` | Enable Basic Auth (true/false) | `false` |
| `ALLOWED_IP` | IP allowed to bypass Basic Auth | `` |

### Notes

- **Database Access:** The internal MariaDB is not exposed by default (runs on port 3306 as root/root). For production, use a separate database container.
- **Database Persistence:** The MariaDB data lives in `/var/lib/mysql`, declared as a `VOLUME`. **Always mount a persistent volume there** (e.g. `-v wordpress-db:/var/lib/mysql`) — otherwise the database sits in the container's writable layer and is **deleted when the container is removed** (e.g. during an image rebuild / `docker rm` + `docker run`). Named volumes survive container recreation, so the site keeps its data across image updates.
- **Content Persistence:** Mount a volume to `/content` to persist your custom themes, plugins, and uploads. On the first run, contents are copied to `/var/www/html/wp-content`.
- **Init System:** This image uses Nitro to manage Apache and MariaDB, ensuring correct boot order and service reliability.
- **Non-root user**: Currently, the `Dockerfile` uses `php:apache` which runs as root to start Apache, then switches to `www-data`. However, the overall container process usually starts as root.
- **Filesystem Permissions**: Ensuring `/var/www/html` is only writable by `www-data` where necessary.
- **Remove build-time tools**: The `Dockerfile` already has some `apt-get purge` logic.
- **Read-only filesystem**: Not always possible for WP, but we can make certain parts read-only.
- **Removing unnecessary packages**: Already doing some `no-install-recommends`.

## Database Backup & Migration

The database is in the `wordpress-db` volume, so back it up before destructive operations (image rebuilds, `docker rm`):

```bash
# Dump to a file on the host (the image ships with mysqldump):
docker exec wordpress mysqldump -uroot -proot --all-databases > wp-backup.sql

# Restore into a (re)created container:
docker exec -i wordpress mysql -uroot -proot < wp-backup.sql
```

### Migrating an existing instance (DB still in the writable layer)

If a running instance predates the persistence fix (its DB is in the container's writable layer, not a volume), move it to a named volume:

```bash
# 1. Dump the existing DB from the running container
docker exec wordpress mysqldump -uroot -proot --all-databases > /root/wp-migrate.sql

# 2. Recreate the container with the new image + the DB volume
docker rm -f wordpress
docker run -d --name=wordpress -v wp-content:/content -v wordpress-db:/var/lib/mysql \
    -e URL="https://your.site" -e ADMIN_NAME=admin -e ADMIN_PASSWORD=... \
    deb-wordpress:latest

# 3. After first-run init completes, restore the dump
docker exec -i wordpress mysql -uroot -proot < /root/wp-migrate.sql
```

---
If you appreciate this work, please consider buying me a beer! :D
[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate?hosted_button_id=KKQ4LNMEDVUPN)