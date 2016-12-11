#!/bin/sh
exec /sbin/setuser www-data \
    /usr/bin/php /var/www/rss/update_daemon2.php
