# Nginx (proxy) frontend image
FROM nicloud/base
MAINTAINER Florin Stancu <niflostancu@gmail.com>

RUN apk --no-cache add nginx ca-certificates certbot

# expose nginx HTTP
EXPOSE 80

# add config and init scripts
ADD init/nginx.sh /etc/service/nginx/run

ADD conf /etc/nginx
ADD webroot /var/www

RUN chown nginx:www-data /var/www -R && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    mkdir -p /run/nginx && \
    mkdir -p /var/www/letsencrypt/.well-known/acme-challenge

