# TinyTinyRSS (nginx based) image for personal cloud
FROM phusion/baseimage
MAINTAINER Florin Stancu <niflostancu@gmail.com>

CMD ["/sbin/my_init"]

ENV SERVICE_UID=1000 USER=www-data
RUN userdel $USER; useradd -u $SERVICE_UID -s /bin/false $USER

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
    nginx supervisor php7.0-fpm php7.0-cli php7.0-curl php7.0-gd php7.0-json \
    php7.0-pgsql php7.0-mysql php7.0-mcrypt php7.0-dom php7.0-mbstring git ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /run/php
RUN chown www-data:www-data /var/www -R

# expose nginx HTTP
EXPOSE 80

# add config and init scripts
ADD init/nginx.sh /etc/service/nginx/run
ADD init/php-fpm.sh /etc/service/php-fpm/run
ADD init/ttrss-update-daemon.sh /etc/service/ttrss-update-daemon/run

ADD conf/php-overrides.ini /etc/php/7.0/fpm/conf.d/99-overrides.ini
ADD conf/nginx-default.conf /etc/nginx/sites-available/default

ADD scripts /usr/local/bin

