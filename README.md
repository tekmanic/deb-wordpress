# deb-wordpress

A specialized Docker image providing a Debian Bullseye-based WordPress environment with an internal MariaDB instance and automated plugin installation.

## Overview
This repository is designed for creating WordPress sandbox environments. It allows you to run multiple isolated WordPress installations in parallel without conflicts, making it ideal for development and testing.

## Key Features
- **Integrated Database:** Includes an internal MariaDB server for zero-config startup.
- **Automated Setup:** Uses WP-CLI for automated site installation and plugin activation.
- **Persistent Content:** Supports Docker volumes for persisting themes, plugins, and uploads.
- **Security:** Includes optional Basic Auth and IP restriction for protected environments.

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
- **Content Persistence:** Mount a volume to `/content` to persist your custom themes, plugins, and uploads. On the first run, contents are copied to `/var/www/html/wp-content`.

---
If you appreciate this work, please consider buying me a beer! :D
[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate?hosted_button_id=KKQ4LNMEDVUPN)