from alpine:3.20

run apk update && apk upgrade && apk add nginx && mkdir -p /var/www/html

copy conf/nginx.conf /etc/nginx/http.d/nginx.conf

run \
	apk add openssl && \
	openssl \
		req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/nginx-selfsigned.key \
		-out /etc/ssl/certs/nginx-selfsigned.crt \
		-subj '/C=FR/ST=IDF/L=Paris/O=42Network/OU=42Paris/CN=vfedorov.42.fr' \
	&& \
true

entrypoint ["env", "-i", "/usr/sbin/nginx", "-g", "daemon off;"]
