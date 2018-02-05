#!/bin/bash

rm -f /var/tmp/phd/log/daemons.log
ln -s /dev/stderr /var/tmp/phd/log/daemons.log

chpst -u phabricator -- /srv/phabricator/bin/phd start

sleep 3
while true; do
    if ! pgrep -f 'phd-daemon' >/dev/null 2>&1; then
        echo "PHD Stopped"
        exit 1
    fi
    sleep 5
done

