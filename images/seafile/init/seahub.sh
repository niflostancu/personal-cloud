#!/bin/bash

# initialize the environment
source /etc/profile.d/python-local.sh   

set -e

if [[ -z "$LANG" ]]; then
    echo "LANG is not set in ENV, set to en_US.UTF-8"
    export LANG='en_US.UTF-8'
fi
if [[ -z "$LC_ALL" ]]; then
    echo "LC_ALL is not set in ENV, set to en_US.UTF-8"
    export LC_ALL='en_US.UTF-8'
fi

export CCNET_CONF_DIR=${SEAFILE_HOME}/ccnet
export SEAFILE_CONF_DIR=${SEAFILE_DATA_DIR}
export SEAFILE_CENTRAL_CONF_DIR=${SEAFILE_HOME}/conf

SEAFILE_SERVER_DIR=${SEAFILE_HOME}/seafile-server
manage_py=${SEAFILE_SERVER_DIR}/seahub/manage.py

cd "${SEAFILE_SERVER_DIR}/seahub/"

if ! chpst -u seafile -- python "/usr/local/share/seafile/scripts/check_init_admin.py"; then
    exit 1
fi

if [[ "${FASTCGI}" =~ [Tt]rue ]]; then
    echo "Running Seahub in fastcgi mode..."
    exec chpst -u seafile -- python "${manage_py}" runfcgi \
        host=0.0.0.0 port=8000 daemonize=false
else
    echo "Running Seahub in gunicorn mode..."
    exec chpst -u seafile -- gunicorn seahub.wsgi:application \
        -b "0.0.0.0:8000" --preload
fi

