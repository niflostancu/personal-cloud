#!/bin/bash
# MySQL data volume initialization script

set -e

if [ -d "/var/lib/mysql/mysql" ]; then
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
        rm -rf "/var/lib/mysql/"*
    else
        echo "The current MySQL data volume was left unchanged."
        exit 0
    fi
fi

echo "Initializing the MySQL data volume..."
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    while true; do
        read -s -p "Enter the MySQL root password: " MYSQL_ROOT_PASSWORD
        echo
        read -s -p "Enter the MySQL root password (confirmation): " MYSQL_ROOT_PASSWORD2
        echo
        [ -n "$MYSQL_ROOT_PASSWORD" ] && [ "$MYSQL_ROOT_PASSWORD" = "$MYSQL_ROOT_PASSWORD2" ] && break
        echo "The password is invalid / does not match! Please try again..."
    done
fi

chown -R mysql:mysql "/var/lib/mysql"

echo 'Initializing database...'

mysql_install_db --user=mysql

/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 <<-EOSQL
    USE mysql;
    DELETE FROM mysql.user WHERE 1;
    FLUSH PRIVILEGES;
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
EOSQL

echo 'The MySQL data volume was successfully initialized.'
exit 0

