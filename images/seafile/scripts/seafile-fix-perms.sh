#!/bin/bash

chown seafile:seafile "$SEAFILE_HOME"
chown seafile:seafile "$SEAFILE_DATA_DIR"

if [ "$1" = "-R" ]; then
    chown seafile:seafile "$SEAFILE_HOME" -R
    chown seafile:seafile "$SEAFILE_DATA_DIR" -R
fi

