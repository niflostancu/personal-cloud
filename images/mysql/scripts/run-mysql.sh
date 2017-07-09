#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql/" ]; then
    echo "The MySQL data volume was not initialized!" 1>&2
    exit 1
fi

exec /usr/bin/mysqld --user=mysql --console "$@"

