from alpine:3.20

run apk update && apk upgrade && apk add mariadb mariadb-client

copy conf/create_db.sh /tmp/\create_db.sh

run chmod +x /tmp/\create_db.sh

entrypoint /tmp/\create_db.sh
