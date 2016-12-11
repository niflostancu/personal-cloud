# Generic MySQL container image
FROM phusion/baseimage
MAINTAINER Florin Stancu <niflostancu@gmail.com>

CMD ["/sbin/my_init"]

ENV SERVICE_UID=1000 USER=mysql
RUN useradd -u $SERVICE_UID -s /bin/false $USER

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
    mysql-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/mysql/*

VOLUME /var/lib/mysql
EXPOSE 3306

# Copy the default configuration files
ADD conf/my.cnf /etc/mysql/my.cnf

# Container scripts
ADD scripts /opt/container/scripts
ADD init/mysql.sh /etc/service/mysql/run

