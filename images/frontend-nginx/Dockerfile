# Nginx (proxy) frontend image
FROM phusion/baseimage
MAINTAINER Florin Stancu <niflostancu@gmail.com>

CMD ["/sbin/my_init"]

ENV SERVICE_UID=1000 USER=www-data
RUN userdel $USER; useradd -u $SERVICE_UID -s /bin/false $USER

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
    nginx ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chown www-data:www-data /var/www -R

# expose nginx HTTP
EXPOSE 80

# add config and init scripts
ADD init/nginx.sh /etc/service/nginx/run

ADD conf /etc/nginx
ADD webroot /var/www

