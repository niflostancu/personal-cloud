#!/bin/bash
# MySQL data volume initialization script
# Some code borrowed from the official MySQL Docker image:
# https://github.com/docker-library/mysql/blob/master/5.5/docker-entrypoint.sh
# 

SWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$SWD/lib.sh"

DATADIR="$(get_mysql_data_dir)"
check_mysql_data_dir "$DATADIR"

if is_mysql_data_initialized "$DATADIR"; then
    echo -n "A MySQL data directory already exists! Do you want to delete it? [y/N] "
    finish=""
    while [ -z "$finish" ]; do
        read answer
        finish="1"
        if [ "$answer" = '' ]; then
            answer="n"
        else
            case $answer in
                y | Y | yes | YES ) answer="y" ;;
                n | N | no | NO ) answer="n" ;;
                *) finish="";
                    echo -n 'Invalid response -- please reenter: ';
                    ;;
            esac
        fi
    done
    if [ "$answer" = "y" ]; then
        rm -rf "$DATADIR/"*
    else
        echo "The current MySQL data volume was left unchanged."
        exit 0
    fi
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    while true; do
        read -s -p "Enter the MySQL root password: " MYSQL_ROOT_PASSWORD
        echo
        read -s -p "Enter the MySQL root password (confirmation): " MYSQL_ROOT_PASSWORD2
        echo
        [ -n "$MYSQL_ROOT_PASSWORD" ] && [ "$MYSQL_ROOT_PASSWORD" = "$MYSQL_ROOT_PASSWORD2" ] && break
        echo "The passwords do not match! Please try again..."
    done
fi

chown -R $USER:$USER "$DATADIR"

echo 'Initializing database...'
mysqld --initialize-insecure

mysqld --skip-networking &
MYSQL_PID="$!"

function mysql_term_handler() {
    kill -SIGTERM "$MYSQL_PID"
    wait "$MYSQL_PID"
    exit $?
}
trap 'mysql_term_handler' HUP INT TERM QUIT

# The mysql client command to use for configuring / testing
MYSQL_CMD=( mysql --protocol=socket -uroot )

for i in {15..0}; do
    if echo 'SELECT 1' | "${MYSQL_CMD[@]}" &> /dev/null; then
        break
    fi
    echo 'MySQL init process in progress...'
    sleep 2
done
if [ "$i" = 0 ]; then
    echo >&2 'MySQL init process failed.'
    exit 1
fi

mysql_tzinfo_to_sql /usr/share/zoneinfo | "${MYSQL_CMD[@]}" mysql

"${MYSQL_CMD[@]}" <<-EOSQL
    -- What's done in this file shouldn't be replicated
    SET @@SESSION.SQL_LOG_BIN=0;
    DELETE FROM mysql.user ;
    CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
    GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
    DROP DATABASE IF EXISTS test ;
    FLUSH PRIVILEGES ;
EOSQL

if ! kill -s TERM "$MYSQL_PID" || ! wait "$MYSQL_PID"; then
    echo >&2 'MySQL data volume initialization failed.'
    exit 1
fi

echo 'The MySQL data volume was successfully initialized.'
exit 0

