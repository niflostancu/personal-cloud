#!/bin/bash

SWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$SWD/mysql-lib.sh"

DATADIR="$(get_mysql_data_dir)"
if [ -z "$DATADIR" ]; then
    echo "The MySQL config is corrupted!" 1>&2
    kill 1 && exit 1
fi
if ! is_mysql_data_initialized "$DATADIR"; then
    echo "The MySQL data volume was not initialized!" 1>&2
    kill 1 && exit 1
fi

exec mysqld "$@"

