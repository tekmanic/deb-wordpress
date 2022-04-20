TOPDIR=$(PWD)

.PHONY: all build run scan clean
all: build run

scan:
    trivy image --severity HIGH,CRITICAL \
    deb-wordpress:latest > scanresults

run: build
	docker run -d \
        --net="bridge" \
        --name=wordpress \
        -p 8081:80 \
        -e SERVER_NAME=localhost \
        -e URL="http://localhost:8081" \
        -e ADMIN_NAME=admin \
        -e ADMIN_PASSWORD=admin \
        -e ADMIN_EMAIL=admin@domain.com \
        -e PLUGINS='wordpress-seo acf-to-rest-api advanced-custom-fields admin-menu-editor wp-api-menus all-in-one-wp-migration elementor essential-addons-for-elementor-lite contact-form-7' \
        -e TITLE='Wordpress-Title' \
        -e BASIC_AUTH_ENABLED=true \
        -e ALLOWED_IP="172.17.0.10" \
        -v $(TOPDIR)/wp-content:/content \
        deb-wordpress:latest

build:
	docker build \
    -t deb-wordpress:latest .

slim:
	docker-slim build \
    --dockerfile Dockerfile \
    --tag deb-wordpress:slim .

clean:
	docker kill wordpress || true
	docker rm -f wordpress 