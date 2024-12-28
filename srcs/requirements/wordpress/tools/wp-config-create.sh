#!/bin/sh
WP_DIR="/var/www/html/wordpress"


wp core download --allow-root --version='6.5' --path="$WP_DIR"

echo "WP_VERSION=$(wp core version --allow-root --path="$WP_DIR")"

# if [ -f "$WP_DIR/wp-config.php" ]; then
#     $@
#     exit 0
# fi

echo "Creating wp-config.php ..."

DB_NAME=$(cat /run/secrets/db_creds | grep DB_NAME | cut -d '=' -f2 | tr -d '\n')
DB_USER=$(cat /run/secrets/db_creds | grep DB_USER | cut -d '=' -f2 | tr -d '\n')
DB_PASS=$(cat /run/secrets/db_creds | grep DB_PASS | cut -d '=' -f2 | tr -d '\n')

cat << EOF > $WP_DIR/wp-config.php
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
define( 'WP_SITEURL', 'https://vfedorov.42.fr' );
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF

echo "Success: wp-config.php is created"

echo "Waiting for MariaDB to be ready..."
while ! nc -z mariadb 3306; do
    :
done

NGINX_HOST=$(cat /run/secrets/wp_creds | grep NGINX_HOST | cut -d '=' -f2 | tr -d '\n')
TITLE=$(cat /run/secrets/wp_creds | grep TITLE | cut -d '=' -f2 | tr -d '\n')
ADMIN_LOGIN=$(cat /run/secrets/wp_creds | grep ADMIN_LOGIN | cut -d '=' -f2 | tr -d '\n')
ADMIN_PASS=$(cat /run/secrets/wp_creds | grep ADMIN_PASS | cut -d '=' -f2 | tr -d '\n')
ADMIN_MAIL=$(cat /run/secrets/wp_creds | grep ADMIN_MAIL | cut -d '=' -f2 | tr -d '\n')


wp core install --allow-root --path=$WP_DIR \
                --url=$URL \
                --title=$TITLE \
                --admin_user=$ADMIN_LOGIN \
                --admin_password=$ADMIN_PASS \
                --admin_email=$ADMIN_MAIL

USER1_LOGIN=$(cat /run/secrets/wp_creds | grep USER1_LOGIN | cut -d '=' -f2 | tr -d '\n')
USER1_PASS=$(cat /run/secrets/wp_creds | grep USER1_PASS | cut -d '=' -f2 | tr -d '\n')
USER1_ROLE=$(cat /run/secrets/wp_creds | grep USER1_ROLE | cut -d '=' -f2 | tr -d '\n')
USER1_MAIL=$(cat /run/secrets/wp_creds | grep USER1_MAIL | cut -d '=' -f2 | tr -d '\n')

wp user create  --allow-root --path="$WP_DIR" \
                $USER1_LOGIN \
                $USER1_MAIL \
                --user_pass=$USER1_MAIL \
                --role=$USER1_ROLE

wp plugin update --allow-root --path="$WP_DIR" --all

exec $@
