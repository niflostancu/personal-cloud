#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql/" ]; then
    echo "The MySQL data volume was not initialized!" 1>&2
    if [[ -t 0 ]]; then
        exec /usr/local/bin/mysql-init.sh
    else
        echo "Please run the container in interactive mode in order to initialize it" 1>&2
        echo "or mount a volume that contains valid mysql data!" 1>&2
        exit 1
    fi
fi

