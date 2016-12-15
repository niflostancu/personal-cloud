#!/bin/bash

chown seafile:seafile /opt/seafile
chown seafile:seafile /var/seafile

if [ "$1" = "-R" ]; then
    chown seafile:seafile /opt/seafile -R
    chown seafile:seafile /var/seafile -R
fi

