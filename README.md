# deb-wordpress

[![docker-tag-triggered-prod](https://github.com/tekmanic/deb-wordpress/actions/workflows/docker-tag-triggered-prod.yaml/badge.svg)](https://github.com/tekmanic/deb-wordpress/actions/workflows/docker-tag-triggered-prod.yaml)

Wordpress based on debian bullseye with internal Mariadb and automated plugin installs.  This has been created for wordpress sandbox environments so that you can run multiple wordpress installations in parallel and not have them step all over one another.

## Using

To run:

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

### Notes

Make sure the plugins are separated by a space.

The internal mariadb is not exposed by default. It runs on port 3306 with user root and password root.  It is not intended to expose Mariadb externally; if that is required, it is suggested to use separate wordpress and mariadb containers.

If you have custom content, images, plugins, etc... add a wp-content directory and make it a docker volume.  On the container's firt run, it will copy the contents into var/www/html.

If you want basic auth used over the entire wordpress site, set BASIC_AUTH_ENABLED=true in the container.  ALLOWED_IP will restrict the site access to 1 IP.  The basic auth will use the same admin credentials as wordpress admin.

---

If you appreciate my work, then please consider buying me a beer :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/donate?hosted_button_id=KKQ4LNMEDVUPN)
