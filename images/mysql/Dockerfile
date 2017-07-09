# Generic MySQL container image
FROM nicloud/base
MAINTAINER Florin Stancu <niflostancu@gmail.com>

ENV MYSQL_UID=1000
RUN userdel mysql; useradd -u $MYSQL_UID -s /bin/false mysql

RUN apk --update --no-cache add mariadb mariadb-client pwgen 

VOLUME /var/lib/mysql
EXPOSE 3306

# Copy the default configuration files
ADD conf/my.cnf /etc/mysql/my.cnf

# Container scripts
ADD scripts /usr/local/bin/
ADD init/check-mysql.sh /etc/startup.d/00-check-mysql.sh
ADD init/mysql.sh /etc/service/mysql/run

