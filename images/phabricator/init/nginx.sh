#!/bin/sh

rm -f /var/log/nginx/access.log
rm -f /var/log/nginx/error.log
ln -s /dev/stderr /var/log/nginx/error.log
ln -s /dev/stdout /var/log/nginx/access.log

exec /usr/sbin/nginx -g "daemon off;"

