#!/bin/bash

rm -f /etc/nginx/sites-enabled/* 2>/dev/null

OVERRIDES_DIR="/etc/nginx.overrides"

DEFAULT_SNIPPETS_DIR="/etc/nginx/snippets/default"
SECURE_SNIPPETS_DIR="/etc/nginx/snippets/default-ssl"
INSECURE_SNIPPETS_DIR="/etc/nginx/snippets/default-ssl/insecure"

DEFAULT_SNIPPETS_ENDIR="/etc/nginx/snippets-enabled/default"
SECURE_SNIPPETS_ENDIR="/etc/nginx/snippets-enabled/default-ssl"
INSECURE_SNIPPETS_ENDIR="/etc/nginx/snippets-enabled/default-ssl/insecure"

# check if SSL is enabled
if [[ "$SSL_ENABLED" =~ [Tt]rue ]]; then
    ln -s /etc/nginx/sites-available/default-ssl /etc/nginx/sites-enabled/default-ssl
    echo "Enabled default-ssl server (with SSL)"
else
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
    echo "Enabled default server (no SSL)"
fi

# first, copy configuration overrides
cp -r "$OVERRIDES_DIR/." "/etc/nginx/"

# activate default snippets
mkdir -p "$DEFAULT_SNIPPETS_ENDIR"
mkdir -p "$INSECURE_SNIPPETS_ENDIR"

if [[ -n "$DEFAULT_SNIPPETS" ]]; then
    for snippet in $DEFAULT_SNIPPETS; do
        if [[ "$SSL_ENABLED" =~ [Tt]rue ]]; then
            if [[ -f "$SECURE_SNIPPETS_DIR/$snippet.conf" ]]; then
                ln -s "$SECURE_SNIPPETS_DIR/$snippet.conf" "$SECURE_SNIPPETS_ENDIR/$snippet.conf"
            elif [[ -f "$DEFAULT_SNIPPETS_DIR/$snippet.conf" ]]; then
                ln -s "$DEFAULT_SNIPPETS_DIR/$snippet.conf" "$SECURE_SNIPPETS_ENDIR/$snippet.conf"
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

