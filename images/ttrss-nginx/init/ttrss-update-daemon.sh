#!/bin/sh

while [[ ! -f "/var/www/rss/config.php" ]]; do
    sleep 5
done

exec chpst -u nginx -- \
    /usr/bin/php7 /var/www/rss/update_daemon2.php
