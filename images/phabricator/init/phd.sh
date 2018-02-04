#!/bin/bash
chpst -u phabricator -- /srv/phabricator/bin/phd start

sleep 3
while true; do
    if ! pgrep -f 'phd-daemon' >/dev/null 2>&1; then
        echo "PHD Stopped"
        exit 1
    fi
    sleep 5
done

