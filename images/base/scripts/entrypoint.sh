#!/bin/bash

# Workaround for docker compose not opening the terminal right away
# https://github.com/docker/compose/issues/4076
if [[ -t 0 ]]; then
    sleep 0.1
fi

exec "$@"

