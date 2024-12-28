from alpine:3.20

run \
	apk update && apk upgrade && \
	apk add \
		php83 \
		php83-fpm \
		php83-bcmath \
		php83-bz2 \
		php83-calendar \
		php83-cli \
		php83-ctype \
		php83-curl \
		php83-dom \
		php83-exif \
		php83-fileinfo \
		php83-gd \
		php83-gmp \
		php83-iconv \
		php83-imap \
		php83-intl \
		php83-json \
		php83-mbstring \
		php83-mysqli \
		php83-mysqlnd \
		php83-openssl \
		php83-pcntl \
		php83-pdo \
		php83-pdo_mysql \
		php83-pdo_pgsql \
		php83-pdo_sqlite \
		php83-pgsql \
		php83-phar \
		php83-posix \
		php83-session \
		php83-shmop \
		php83-simplexml \
		php83-soap \
		php83-sockets \
		php83-sodium \
		php83-sqlite3 \
		php83-sysvsem \
		php83-sysvshm \
		php83-tokenizer \
		php83-xml \
		php83-xmlreader \
		php83-xmlwriter \
		php83-xsl \
		php83-zip \
		php83-zlib \
		mariadb-client 

run sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf

#run \
#	apk add curl && \
#	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
#	chmod +x wp-cli.phar && \
#	mv wp-cli.phar /usr/bin/wp-cli.phar

RUN wget https://github.com/wp-cli/wp-cli/releases/download/v2.10.0/wp-cli-2.10.0.phar && \
    php wp-cli-2.10.0.phar --info && \
    chmod +x wp-cli-2.10.0.phar && \
    mv wp-cli-2.10.0.phar /usr/local/bin/wp

RUN wp core download --allow-root --version='6.5' --path='/var/www/' && \
    wp core version --allow-root --path='/var/www/' && \
    chmod -R 0777 /var/www/wp-content

copy ./requirements/wordpress/conf/wp-config-create.sh /var/www/
run chmod +x ./var/www/wp-config-create.sh

run \
    if [ -L /usr/bin/php ]; then rm /usr/bin/php; fi && \
    ln -s /usr/bin/php83 /usr/bin/php

workdir /var/www/wp-config-create

entrypoint ["/var/www/wp-config-create.sh"]
cmd ["php-fpm83 -F"]
