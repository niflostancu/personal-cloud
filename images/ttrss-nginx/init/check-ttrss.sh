#!/bin/bash
#
# Runs some preliminary checks before starting the main services.
#

set -e

sleep 1

WWW_PATH=/var/www
TTRSS_PATH=/var/www/rss

# First, fix directory permissions
chown nginx:nginx "$WWW_PATH"

# Check if ttrss is installed
if [[ ! -d "${TTRSS_PATH}/.git" ]]; then
    echo
    echo "No TT-RSS installation found, downloading..."
    chpst -u nginx -- ttrss-update-git.sh
fi

if [[ ! -f "${TTRSS_PATH}/config.php" ]]; then
    echo
    echo "Note: TT-RSS doesn't seem to be configured!"
    echo "After the server starts, please go to http://HOST:PORT/rss/install/"
    echo "and follow the instructions to finish your installation."
    echo
fi

