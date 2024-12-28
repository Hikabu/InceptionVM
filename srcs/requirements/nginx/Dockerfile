from alpine:3.20

run apk update && apk upgrade && apk add --no-cache nginx openssl

copy ./conf/default.conf /etc/nginx/http.d/default.conf
# copy ./requirements/nginx/conf/mine.conf /etc/nginx/http.d/mine.conf

run \
	apk add openssl && \
	openssl \
		req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/nginx-selfsigned.key \
		-out /etc/ssl/certs/nginx-selfsigned.crt \
		-subj '/C=FR/ST=IDF/L=Paris/O=42Network/OU=42Paris/CN=vfedorov.42.fr' \
	&& \
true
expose 443
entrypoint ["nginx", "-g", "daemon off;"]
