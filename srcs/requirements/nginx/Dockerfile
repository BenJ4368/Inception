FROM debian:bullseye 

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
	nginx \
	openssl \
  && mkdir /etc/nginx/ssl \
  && openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
	-out /etc/nginx/ssl/bgaertne.crt \
	-keyout /etc/nginx/ssl/bgaertne.key \
	-subj "/C=FR/ST=MULHOUSE/L=MULHOUSE/O=42 School/OU=bgaertne/CN=bgaertne/"

EXPOSE 443

COPY ./conf/default /etc/nginx/sites-available/.

CMD ["nginx", "-g", "daemon off;"]

