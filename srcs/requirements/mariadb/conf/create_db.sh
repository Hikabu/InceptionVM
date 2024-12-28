#!bin/sh

if [ ! -d "/var/lib/mysql/mysql" ]; then

        chown -R mysql:mysql /var/lib/mysql

        # init database
        mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm

        tfile=`mktemp`
        if [ ! -f "$tfile" ]; then
                return 1
        fi
fi

DB_NAME=$(cat /run/secrets/db_creds | grep DB_NAME | cut -d '=' -f2 | tr -d '\n')
DB_USER=$(cat /run/secrets/db_creds | grep DB_USER | cut -d '=' -f2 | tr -d '\n')
DB_PASS=$(cat /run/secrets/db_creds | grep DB_PASS | cut -d '=' -f2 | tr -d '\n')
DB_ROOT=$(cat /run/secrets/db_root | tr -d '\n')

echo "$DB_NAME : $DB_USER : $DB_PASS : $DB_ROOT"

if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then

    echo "Creating mariadb database [${DB_NAME}] ..."

    cat << EOF > /tmp/create_db.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM     mysql.user WHERE User='';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${DB_USER}'@'%' IDENTIFIED by '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    # project init.sql
    echo "Running mariadb database [${DB_NAME}] ..."
    /usr/bin/mysqld --user=mysql --bootstrap < /tmp/create_db.sql
    rm -f /tmp/create_db.sql
    echo "Success: mariadb database [${DB_NAME}] is created and run"

fi

exec "$@"
