# Seafile server image
FROM nicloud/base
MAINTAINER Florin Stancu <niflostancu@gmail.com>

ENV SEAFILE_UID=1000 \
    SEAFILE_HOME="/home/seafile" \
    SEAFILE_DATA_DIR="/var/lib/seafile" \
    SEAFILE_VERSION="6.1.0"

# Main build script
COPY build.sh /tmp/build.sh
COPY seafile-server.patch /tmp/seafile-server.patch
# Execute our build script and delete it because we won't need it anymore
RUN /tmp/build.sh "$SEAFILE_VERSION" "$SEAFILE_SERVER_DIR" && rm /tmp/build.sh

EXPOSE 8000 8082
VOLUME /home/seafile
VOLUME /var/lib/seafile

# Container scripts
ADD scripts /usr/local/bin/

# Init Scripts
ADD init/check-seafile.sh /etc/startup.d/00-check-seafile.sh
ADD init/seafile.sh /etc/service/seafile/run
ADD init/seahub.sh /etc/service/seahub/run

