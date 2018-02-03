# Base image
FROM alpine:3.6
MAINTAINER Florin Stancu <niflostancu@gmail.com>

# Install common packages
RUN apk --update upgrade
RUN apk --update --no-cache add runit shadow bash tzdata

# Add files
ADD scripts/start_runit /sbin/
ADD scripts/entrypoint.sh /sbin/docker-entrypoint.sh
ADD scripts/init-timezone /etc/startup.d/01-init-timezone

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
CMD ["/sbin/start_runit"]

