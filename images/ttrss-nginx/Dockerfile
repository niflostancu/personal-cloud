# TinyTinyRSS (nginx based) image for personal cloud
FROM nicloud/base
MAINTAINER Florin Stancu <niflostancu@gmail.com>

ENV WWW_UID=1000
RUN userdel nginx; useradd -u $WWW_UID -s /bin/false nginx

RUN apk --update --no-cache add \
    nginx php7-fpm php7 php7-curl php7-gd php7-json \
    php7-pgsql php7-mysqli php7-mcrypt php7-dom php7-mbstring git ca-certificates

RUN mkdir -p /run/php && mkdir -p /run/nginx

# expose nginx HTTP
VOLUME /var/www
EXPOSE 80

# add config and init scripts
ADD init/check-ttrss.sh /etc/startup.d/00-check-ttrss.sh
ADD init/nginx.sh /etc/service/nginx/run
ADD init/php-fpm.sh /etc/service/php-fpm/run
ADD init/ttrss-update-daemon.sh /etc/service/ttrss-update-daemon/run

ADD conf/php-overrides.ini /etc/php7/fpm/conf.d/99-overrides.ini
ADD conf/nginx-default.conf /etc/nginx/conf.d/default.conf

ADD scripts /usr/local/bin

