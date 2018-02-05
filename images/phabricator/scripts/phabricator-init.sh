#!/bin/bash
# Phabricator initialization / check script

set -e

if [ -t 0 ]; then
    INTERACTIVE=1
fi

PHB_PATH=/srv/phabricator

function as_phb() {
    chpst -u phabricator -- "$@"
}

function phb_config_get() {
    as_phb "$PHB_PATH/bin/config" get "$1" | jq -r '.config[0].value' | grep -v '^null$'
}

function phb_storage_check() {
    as_phb "$PHB_PATH/bin/storage" --dryrun
}

function phb_config_mysql() {
    if ! [[ $INTERACTIVE -eq 1 ]]; then
        echo "Phabricator is not configured, please run the container in interactive mode!"
        exit 1
    fi
    for i in 1 2 3; do
        if [[ -z "$MYSQL_ROOT_PASSWORD" ]]; then
            read -s -p "Please enter the MySQL root password for auto-configuration: " MYSQL_ROOT_PASSWORD
            echo
        fi
        if ! mysql -h mysql -u root "-p$MYSQL_ROOT_PASSWORD" -e ";"; then
            echo "Invalid MySQL root credentials!"
            MYSQL_ROOT_PASSWORD=
            continue
        fi

        if [[ -z "$MYSQL_USER" ]]; then
            read -p "MySQL phabricator user to be created [phabricator]: " MYSQL_USER
            echo
        fi
        MYSQL_USER=${MYSQL_USER:-phabricator}
        if [[ -z "$MYSQL_PASSWORD" ]]; then
            read -s -p "MySQL phabricator password (empty to auto-generate one): " MYSQL_PASSWORD
            echo
        fi
        if [[ -z "$MYSQL_PASSWORD" ]]; then
            # randomly generate a password
            MYSQL_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        fi

        mysql -h mysql -u root "-p$MYSQL_ROOT_PASSWORD" <<-EOSQL
            USE mysql;
            DROP USER IF EXISTS '${MYSQL_USER}'@'%', '${MYSQL_USER}'@'localhost';
            CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
            GRANT ALL ON \`phabricator\\_%\`.* TO '${MYSQL_USER}'@'%';
EOSQL

        as_phb "$PHB_PATH/bin/config" set mysql.host "mysql"
        as_phb "$PHB_PATH/bin/config" set mysql.user "${MYSQL_USER}"
        as_phb "$PHB_PATH/bin/config" set mysql.pass "${MYSQL_PASSWORD}"

        if as_phb "$PHB_PATH/bin/storage" upgrade --force; then
            # success!
            return
        else
            [[ "$i" = "3" ]] && break
            echo "The supplied phabricator configuration is invalid. Retrying..."
        fi
        MYSQL_PASSWORD=
        MYSQL_USER=
    done
    echo "Phabricator MySQL configuration failed!"
    echo "Please remove the phabricator databases and its previous users and try again!"
    exit 1
}

if [[ ! -f "$PHB_PATH/conf/__init_conf__.php" ]]; then
    cp -a "$PHB_PATH/conf.orig/." "$PHB_PATH/conf/"
fi

# Configure date.timezone for PHP
if [[ -n "$TZ" ]]; then
    echo "date.timezone=$TZ" > /etc/php7/conf.d/99-timezone.ini
fi

# Fix repository permissions
chown phabricator:phabricator /var/repo

if [[ -z "$(phb_config_get phd.user)" ]] || \
        [[ -z "$(phb_config_get diffusion.ssh-user)" ]]; then
    as_phb "$PHB_PATH/bin/config" set phd.user phabricator
    as_phb "$PHB_PATH/bin/config" set diffusion.ssh-user git
fi

DIFFUSION_SSH_PORT="${DIFFUSION_SSH_PORT:-2222}"
if [[ "$(phb_config_get diffusion.ssh-port)" != "${DIFFUSION_SSH_PORT}" ]]; then
    as_phb "$PHB_PATH/bin/config" set diffusion.ssh-port "${DIFFUSION_SSH_PORT}"
fi

if [[ -z "$(phb_config_get mysql.host)" ]] || \
        [[ -z "$(phb_config_get mysql.user)" ]] || \
        [[ -z "$(phb_config_get mysql.pass)" ]] || \
        ! as_phb "$PHB_PATH/bin/storage" upgrade --force; then
    echo "Phabricator is not properly configured, running the setup script..."
    phb_config_mysql
fi

as_phb "$PHB_PATH/bin/storage" upgrade --force

