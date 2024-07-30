FROM debian:bullseye

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
        php7.4-fpm \
	php7.4-mysqli \
	curl

RUN mkdir -p /run/php

COPY ./conf/www.conf etc/php/7.4/fpm/pool.d/.
COPY ./conf/script.sh .
RUN chmod +x script.sh

EXPOSE 9000

CMD ["./script.sh"]
