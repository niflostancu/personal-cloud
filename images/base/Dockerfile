# Base image
FROM alpine:3.6
MAINTAINER Florin Stancu <niflostancu@gmail.com>

# Install common packages
RUN apk --update --no-cache add runit shadow bash

# Add files
ADD scripts/start_runit /sbin/
RUN mkdir -p /etc/startup.d

CMD ["/sbin/start_runit"]

