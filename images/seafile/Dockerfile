# Seafile server image
FROM phusion/baseimage
MAINTAINER Florin Stancu <niflostancu@gmail.com>

CMD ["/sbin/my_init"]

ENV SERVICE_UID=1000 USER=seafile
RUN userdel $USER; useradd -u $SERVICE_UID -s /bin/false $USER

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
    python2.7 libpython2.7 python-setuptools python-imaging \
    python-simplejson python-ldap python-mysqldb python-urllib3 python-memcache \
    wget curl jq ca-certificates netcat-openbsd socat && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /opt/seafile
VOLUME /var/seafile

EXPOSE 10001 12001 8000 8080 8082

# Container scripts
ADD scripts /usr/local/bin/
# Daemons
ADD init/seafile.sh /etc/service/seafile/run
ADD init/seahub.sh /etc/service/seahub/run
ADD init/fix-perms.sh /etc/my_init.d/00-fix-perms.sh
ADD init/fix-perms.sh /usr/local/bin/fix-perms.sh

