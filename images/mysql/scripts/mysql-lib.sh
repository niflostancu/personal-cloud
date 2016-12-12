#!/bin/bash
# Configuration / common utility script for the mysql container

function get_mysql_config() {
    echo $(mysqld --verbose --help --log-bin-index=`mktemp -u` 2>/dev/null | \
        awk '$1 == "'$1'" { print $2; exit }')
}

function get_mysql_data_dir() {
    echo $(get_mysql_config datadir)
}

function check_mysql_data_dir() {
    if [ -z "$1" ]; then
        echo "The MySQL data directory could not be determined!" 1>&2
        exit 1
    fi
}

function is_mysql_data_initialized() {
    shopt -s nullglob
    local DATADIR="$1"
    local DATA_FILES=("$DATADIR/"*)
    [ "${#DATA_FILES[@]}" -gt 0 ] && return 0
    return 1
}

