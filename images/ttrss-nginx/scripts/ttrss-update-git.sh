#!/bin/bash
# Tiny Tiny RSS automatic initialization / upgrade script

TTRSS_PATH=/var/www/rss
TTRSS_CLONE_PATH=/opt/container/ttrss
TTRSS_CONFIG=/opt/container/ttrss-config.php

set -e

if [ ! -d "$TTRSS_PATH/.git" ]; then
    # First time, install it (clone from official repo)
    echo "Cloning Tiny Tiny RSS repo..."
    if [ -d "$TTRSS_CLONE_PATH" ]; then
        cp -r "$TTRSS_CLONE_PATH" "$TTRSS_PATH"
    else
        git clone https://tt-rss.org/git/tt-rss.git "$TTRSS_PATH"
    fi
fi

cd "$TTRSS_PATH"
git reset --hard HEAD
git pull origin master

# Override ttrss's config
if [ -f "$TTRSS_CONFIG" ]; then
    cp -f "$TTRSS_CONFIG" "$TTRSS_PATH/config.php"
fi

# install / update additional plugins / themes
function ttrss_install_plugin()
{
    local PLUG_DIR="/var/www/rss-plugins/$2"
    if cd "$PLUG_DIR"; then git pull; else git clone "$1" "$PLUG_DIR"; fi
    if [ "$3" == "plugin" ]; then
        ln -s "$PLUG_DIR/$2" "$TTRSS_PATH/plugins.local/$2" || true
    elif [ "$3" == "theme" ]; then
        ln -s "$PLUG_DIR/$2" "$TTRSS_PATH/themes.local/$2" || true
        ln -s "$PLUG_DIR/$2.css" "$TTRSS_PATH/themes.local/$2.css" || true
    fi
}

mkdir -p /var/www/rss-plugins/
ttrss_install_plugin "https://github.com/dasmurphy/tinytinyrss-fever-plugin.git" fever plugin
ttrss_install_plugin "https://github.com/levito/tt-rss-feedly-theme.git" feedly theme

if [ "$1" == "+installdb" ]; then
    ttrss-install.php
fi

