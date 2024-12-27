from alpine:3.20

RUN apk update && apk upgrade && apk add --no-cache mariadb mariadb-client

RUN mkdir /var/run/mysqld; \
    chmod 777 /var/run/mysqld; \
    { echo '[mysqld]'; \
      echo 'skip-host-cache'; \
      echo 'skip-name-resolve'; \
      echo 'bind-address=0.0.0.0'; \
    } | tee  /etc/my.cnf.d/docker.cnf; \
      sed -i "s|skip-networking|skip-networking=0|g" \
        /etc/my.cnf.d/mariadb-server.cnf

RUN	 mysql_install_db --user=mysql --datadir=/var/lib/mysql

EXPOSE 3306

COPY requirements/mariadb/tools/create_db.sh .

RUN chmod +x ./create_db.sh

USER mysql

ENTRYPOINT ["/create_db.sh"]

CMD ["/usr/bin/mysqld", "--skip-log-error"]


# run apk update && apk upgrade && apk add mariadb mariadb-client

# copy conf/create_db.sh /tmp/\create_db.sh

# run chmod +x /tmp/\create_db.sh

# entrypoint /tmp/\create_db.sh
