# Phabricator image
FROM nicloud/base
MAINTAINER Florin Stancu <niflostancu@gmail.com>

# create nginx before installing the package to use it during install scripts
ENV WWW_UID=998 PHD_UID=999 GIT_UID=1000
RUN useradd -u $WWW_UID -s /bin/false nginx
RUN useradd -u $PHD_UID -s /bin/bash phabricator
RUN useradd -u $GIT_UID -s /bin/false git

RUN apk --update --no-cache add \
    nginx mariadb-client php7-fpm php7 php7-curl php7-gd php7-json php7-pcntl php7-fileinfo \
    php7-xml php7-posix php7-session php7-pgsql php7-mysqli php7-mcrypt \
    php7-mbstring php7-iconv php7-ctype php7-opcache php7-apcu \
    py3-pygments git ca-certificates sudo jq

RUN mkdir -p /run/php && mkdir -p /run/nginx && \
    ln -s /usr/bin/pygmentize-3 /usr/local/bin/pygmentize

# clone phabricator
ADD scripts/phabricator-clone.sh /usr/local/bin/phabricator-clone.sh
RUN phabricator-clone.sh

# expose HTTP and SSH
VOLUME /srv/phabricator/conf/
VOLUME /var/repo
EXPOSE 22 80

# add config and init scripts
ADD init/check-phabricator.sh /etc/startup.d/10-check-phabricator.sh
ADD init/nginx.sh /etc/service/nginx/run
ADD init/php-fpm.sh /etc/service/php-fpm/run
ADD init/phd.sh /etc/service/phd/run

ADD conf/php/php-fpm.ini /etc/php7/fpm/conf.d/99-overrides.ini
ADD conf/php/fpm.conf /etc/php7/php-fpm.d/www.conf
ADD conf/nginx-default.conf /etc/nginx/conf.d/default.conf

ADD scripts /usr/local/bin

