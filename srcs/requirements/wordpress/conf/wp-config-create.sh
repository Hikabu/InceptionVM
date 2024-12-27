#!/bin/sh

echo "[WP config] Configuring WordPress..."

DB_HOST=$(cat /project/secrets/db_creds | grep DB_HOST | cut -d '=' -f2 | tr -d '\n'
WP_DB_NAME=$(cat /project/secrets/db_creds | grep DB_NAME | cut -d '=' -f2 | tr -d '\n')
WP_DB_USER=$(cat /project/secrets/db_creds | grep DB_USER | cut -d '=' -f2 | tr -d '\n')
WP_DB_PASS=$(cat /project/secrets/db_creds | grep DB_PASS | cut -d '=' -f2 | tr -d '\n'

WP_PATH=/var/www

if [ -f ${WP_PATH}/wp-config.php ]
then
	echo "[WP config] WordPress already configured."
else
	echo "[WP config] Setting up WordPress..."
	echo "[WP config] Updating WP-CLI..."
	wp-cli.phar cli update --yes --allow-root
	echo "[WP config] Downloading WordPress..."
	wp-cli.phar core download --allow-root
	echo "[WP config] Creating wp-config.php..."

	cat << EOF > /var/www/wp-config.php
	<?php
	define( 'DB_NAME', '${DB_NAME}' );
	define( 'DB_USER', '${DB_USER}' );
	define( 'DB_PASSWORD', '${DB_PASS}' );
	define( 'DB_HOST', 'mariadb' );
	define( 'DB_CHARSET', 'utf8' );
	define( 'DB_COLLATE', '' );
	define('FS_METHOD','direct');
	\$table_prefix = 'wp_';
	define( 'WP_DEBUG', false );
	if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );}
	require_once ABSPATH . 'wp-settings.php';
	EOF

	echo "[WP config] Installing WordPress core..."

	echo "[WP config] Creating WordPress default user..."
fi


echo "[WP config] Waiting for MariaDB..."
while ! nc -z mariadb 3306; do
    :
done
echo "[WP config] MariaDB accessible."

NGINX_HOST=$(cat /run/secrets/wp_creds | grep URL | cut -d '=' -f2 | tr -d '\n')
TITLE=$(cat /run/secrets/wp_creds | grep TITLE | cut -d '=' -f2 | tr -d '\n')
ADMIN_LOGIN=$(cat /run/secrets/wp_creds | grep ADMIN_LOGIN | cut -d '=' -f2 | tr -d '\n')
ADMIN_PASS=$(cat /run/secrets/wp_creds | grep ADMIN_PASS | cut -d '=' -f2 | tr -d '\n')
ADMIN_MAIL=$(cat /run/secrets/wp_creds | grep ADMIN_MAIL | cut -d '=' -f2 | tr -d '\n')

wp core install --allow-root --path=/var/www \
                --url=$NGINX_HOST \
                --title=$TITLE \
                --admin_user=$ADMIN_LOGIN \
                --admin_password=$ADMIN_PASS \
                --admin_email=$ADMIN_MAIL

USER1_LOGIN=$(cat /run/secrets/wp_creds | grep USER1_LOGIN | cut -d '=' -f2 | tr -d '\n')
USER1_PASS=$(cat /run/secrets/wp_creds | grep USER1_PASS | cut -d '=' -f2 | tr -d '\n')
USER1_ROLE=$(cat /run/secrets/wp_creds | grep USER1_ROLE | cut -d '=' -f2 | tr -d '\n')
USER1_MAIL=$(cat /run/secrets/wp_creds | grep USER1_MAIL | cut -d '=' -f2 | tr -d '\n')

wp user create  --allow-root --path=/var/www \
                $USER1_LOGIN \
                $USER1_MAIL \
                --user_pass=$USER1_MAIL \
                --role=$USER1_ROLE

wp plugin update --allow-root --path=/var/www --all

$@

echo "[WP config] Starting WordPress fastCGI on port 9000."
exec env -i /usr/sbin/php-fpm83 -F -R
