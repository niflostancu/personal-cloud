#!/bin/bash

rm -f /var/log/nginx/access.log
rm -f /var/log/nginx/error.log
ln -s /dev/stderr /var/log/nginx/error.log
ln -s /dev/stdout /var/log/nginx/access.log

set -e

OVERRIDES_DIR="/etc/nginx.overrides"

DEFAULT_SNIPPETS_DIR="/etc/nginx/snippets/default"
SECURE_SNIPPETS_DIR="/etc/nginx/snippets/default-ssl"
INSECURE_SNIPPETS_DIR="/etc/nginx/snippets/default-ssl/insecure"

DEFAULT_SNIPPETS_ENDIR="/etc/nginx/snippets-enabled/default"
SECURE_SNIPPETS_ENDIR="/etc/nginx/snippets-enabled/default-ssl"
INSECURE_SNIPPETS_ENDIR="/etc/nginx/snippets-enabled/default-ssl/insecure"

# check if SSL is enabled
rm -f /etc/nginx/sites-enabled/default-ssl /etc/nginx/sites-enabled/default
if [[ "$SSL_ENABLED" =~ [Tt]rue ]]; then
    ln -s /etc/nginx/sites-available/default-ssl /etc/nginx/sites-enabled/default-ssl
    echo "Enabled default-ssl server (with SSL)"
else
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
    echo "Enabled default server (no SSL)"
fi

# first, copy configuration overrides
if [[ -d "$OVERRIDES_DIR" ]]; then
    cp -rf "$OVERRIDES_DIR/." "/etc/nginx/"
fi

# activate default snippets
rm -rf "$DEFAULT_SNIPPETS_ENDIR"
rm -rf "$INSECURE_SNIPPETS_ENDIR"
mkdir -p "$DEFAULT_SNIPPETS_ENDIR"
mkdir -p "$INSECURE_SNIPPETS_ENDIR"

if [[ -n "$DEFAULT_SNIPPETS" ]]; then
    for snippet in $DEFAULT_SNIPPETS; do
        if [[ "$SSL_ENABLED" =~ [Tt]rue ]]; then
            if [[ -f "$SECURE_SNIPPETS_DIR/$snippet.conf" ]]; then
                ln -s "$SECURE_SNIPPETS_DIR/$snippet.conf" "$SECURE_SNIPPETS_ENDIR/$snippet.conf" || true
            elif [[ -f "$DEFAULT_SNIPPETS_DIR/$snippet.conf" ]]; then
                ln -s "$DEFAULT_SNIPPETS_DIR/$snippet.conf" "$SECURE_SNIPPETS_ENDIR/$snippet.conf" || true
            else
                echo "WARNING: default-ssl snippet '$snippet' not found!"
            fi
        else
            ln -s "$DEFAULT_SNIPPETS_DIR/$snippet.conf" "$DEFAULT_SNIPPETS_ENDIR/$snippet.conf" || \
                echo "WARNING: default snippet '$snippet' not found!"
        fi
    done
fi
if [[ -n "$INSECURE_SNIPPETS" ]]; then
    for snippet in $INSECURE_SNIPPETS; do
        ln -s "$INSECURE_SNIPPETS_DIR/$snippet.conf" "$INSECURE_SNIPPETS_ENDIR/$snippet.conf" || \
            echo "WARNING: insecure snippet '$snippet' not found!"
    done
fi

exec /usr/sbin/nginx -g "daemon off;"

