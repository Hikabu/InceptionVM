
#!/bin/sh

if test ! -d /run/mysqld; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi


WB_DB_NAME=$(cat /project/secrets/db_creds | grep DB_NAME | cut -d '=' -f2 | tr -d '\n')
WP_DB_USER=$(cat /project/secrets/db_creds | grep DB_USER | cut -d '=' -f2 | tr -d '\n')
WP_DB_PASS=$(cat /project/secrets/db_creds | grep DB_PASS | cut -d '=' -f2 | tr -d '\n')
DB_ROOT_PASS=$(cat /project/secrets/db_root | tr -d '\n')

if test ! -d /var/lib/mysql/mysql; then
	chown -R mysql:mysql /var/lib/mysql
	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null

	temporary=$(mktemp)
	cat <<- end > "$temporary"
		use mysql;
		flush privileges;
		delete from mysql.user where User='';
		drop table if exists test;
		delete from mysql.db where Db='test';
		delete from mysql.user where User='root' and Host not in (
			'localhost', '127.0.0.1', '::1'
		);
		alter user 'root'@'localhost' identified by '$DB_ROOT_PASS';
		create database $WP_DB_NAME;
		create user '$WP_DB_USER'@'%' identified by '$WP_DB_PASS';
		grant all privileges on $WP_DB_NAME.* to '$WP_DB_USER'@'%' identified by '$WP_DB_PASS';
		flush privileges;
	end

	/usr/bin/mysqld --user=mysql --bootstrap < "$temporary"
	rm -f "$temporary"
fi

sed -i 's/skip-networking/# skip-networking/g' /etc/my.cnf.d/mariadb-server.cnf
sed -i 's/.*bind-address\s*=.*/bind-address=0.0.0.0/g' /etc/my.cnf.d/mariadb-server.cnf

exec env -i /usr/bin/mysqld --user=mysql --console
