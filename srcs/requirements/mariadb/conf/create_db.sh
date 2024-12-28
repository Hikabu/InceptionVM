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

DB_NAME=$(cat project/secrets/db_creds.txt | grep DB_NAME | cut -d '=' -f2 | tr -d '\n')
DB_USER=$(cat project/secrets/db_creds.txt | grep DB_USER | cut -d '=' -f2 | tr -d '\n')
DB_PASS=$(cat project/secrets/db_creds.txt | grep DB_PASS | cut -d '=' -f2 | tr -d '\n')
DB_ROOT=$(cat project/secrets/db_root_pass.txt | tr -d '\n')

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
    echo "Success: mariadb database [${DB_NAME}] is created and project"

fi

exec "$@"


# #!/bin/sh

# if test ! -d /project/mysqld; then
# 	mkdir -p /project/mysqld
# 	chown -R mysql:mysql /project/mysqld
# fi


# WB_DB_NAME=$(cat /project/secrets/db_creds | grep DB_NAME | cut -d '=' -f2 | tr -d '\n')
# WP_DB_USER=$(cat /project/secrets/db_creds | grep DB_USER | cut -d '=' -f2 | tr -d '\n')
# WP_DB_PASS=$(cat /project/secrets/db_creds | grep DB_PASS | cut -d '=' -f2 | tr -d '\n')
# DB_ROOT_PASS=$(cat /project/secrets/db_root | tr -d '\n')

# if test ! -d /var/lib/mysql/mysql; then
# 	chown -R mysql:mysql /var/lib/mysql
# 	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null

# 	temporary=$(mktemp)
# 	cat <<- end > "$temporary"
# 		use mysql;
# 		flush privileges;
# 		delete from mysql.user where User='';
# 		drop table if exists test;
# 		delete from mysql.db where Db='test';
# 		delete from mysql.user where User='root' and Host not in (
# 			'localhost', '127.0.0.1', '::1'
# 		);
# 		alter user 'root'@'localhost' identified by '$DB_ROOT_PASS';
# 		create database $WP_DB_NAME;
# 		create user '$WP_DB_USER'@'%' identified by '$WP_DB_PASS';
# 		grant all privileges on $WP_DB_NAME.* to '$WP_DB_USER'@'%' identified by '$WP_DB_PASS';
# 		flush privileges;
# 	end

# 	/usr/bin/mysqld --user=mysql --bootstrap < "$temporary"
# 	rm -f "$temporary"
# fi

# sed -i 's/skip-networking/# skip-networking/g' /etc/my.cnf.d/mariadb-server.cnf
# sed -i 's/.*bind-address\s*=.*/bind-address=0.0.0.0/g' /etc/my.cnf.d/mariadb-server.cnf

# exec env -i /usr/bin/mysqld --user=mysql --console
