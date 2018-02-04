# User-friendly, alpine-based MySQL image
FROM nicloud/base
MAINTAINER Florin Stancu <niflostancu@gmail.com>

ENV MYSQL_UID=1000
RUN useradd -u $MYSQL_UID -s /bin/false mysql

RUN apk --update --no-cache add mariadb mariadb-client pwgen logrotate dcron

VOLUME /var/lib/mysql
EXPOSE 3306

# Copy the default configuration files
ADD conf/my.cnf /etc/mysql/my.cnf
ADD conf/logrotate-backup.conf /etc/logrotate.custom/mysql-backup
ADD conf/crontab /var/spool/cron/crontabs/root

# Container scripts
ADD scripts /usr/local/bin/
ADD init/check-mysql.sh /etc/startup.d/10-mysql-check.sh
ADD init/mysql.sh /etc/service/mysql/run
ADD init/crond.sh /etc/service/crond/run

