LOGIN = vfedorov
DOMAIN = ${LOGIN}.42.fr
DATA_PATH = /home/${LOGIN}/data
#DATA_PATH = /Users/valeriafedorova/Desktop/inseptopn/t
ENV = LOGIN=${LOGIN} DATA_PATH=${DATA_PATH} DOMAIN=${LOGIN}.42.fr 

.DEFAULT_GOAL := up-no-detach

.PHONY : all
all: up

.PHONY : up
up: setup
	 cd srcs && ${ENV} docker-compose up -d

.PHONY : rebuild-wordpress
rebuild-wordpress :
	cd srcs && ${ENV} docker-compose build --no-cache wordpress

.PHONY : rebuild-wordpress-cached
rebuild-wordpress-cached :
	cd srcs && ${ENV} docker-compose build wordpress

.PHONY : rebuild
rebuild :
	cd srcs && ${ENV} docker-compose build --no-cache

.PHONY : up-no-detach
up-no-detach: setup
	cd srcs && ${ENV} docker-compose up

.PHONY : down
down:
	cd srcs && ${ENV} docker-compose down

.PHONY : start
start:
	cd srcs && ${ENV} docker-compose start

.PHONY : stop
stop:
	cd srcs  && ${ENV} docker-compose stop

.PHONY : status
status:
	cd srcs && docker-compose ps

.PHONY : logs
logs:
	cd srcs && docker-compose logs

.PHONY : setup
setup:
	mkdir -p ${DATA_PATH}/mariadb-data
	mkdir -p ${DATA_PATH}/wordpress-data

.PHONY : clean
clean: stop
	sudo rm -rf ${DATA_PATH}

.PHONY : fclean
fclean: clean
	docker system prune -f -a --volumes || true
	docker stop $$(docker ps -qa) || true
	docker rm $$(docker ps -qa) || true
	docker rmi $$(docker images -qa) || true
	docker volume rm $$(docker volume ls -q) || true
	docker network rm $$(docker network ls -q) 2> /dev/null || true

.PHONY : load-certificate
load-certificate : ; docker exec -it nginx cat /etc/ssl/certs/nginx-selfsigned.crt > certificate

.PHONY : into-nginx
into-nginx: ; docker exec -it nginx sh

.PHONY : curl
curl : load-certificate
	curl --cacert certificate https://vfedorov.42.fr

.PHONY : lynx
lynx : load-certificate
	SSL_CERT_FILE=certificate lynx -accept_all_cookies https://vfedorov.42.fr
