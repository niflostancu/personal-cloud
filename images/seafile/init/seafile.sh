#!/bin/bash

if [[ ! -d "$SEAFILE_HOME/conf" ]]; then
    echo "Seafile configuration directory '$SEAFILE_HOME/conf' does not exist!"
    exit 1
fi

cd ${SEAFILE_HOME}

SEAFILE_ARGS=(\
    -c "${SEAFILE_HOME}/ccnet" \
    -d "${SEAFILE_DATA_DIR}" \
    -F "${SEAFILE_HOME}/conf" )

if ! chpst -u seafile -- seafile-controller --test "${SEAFILE_ARGS[@]}"; then
    echo "Seafile self-test failed!"
    exit 2
fi

exec chpst -u seafile -- seafile-controller -f "${SEAFILE_ARGS[@]}"

