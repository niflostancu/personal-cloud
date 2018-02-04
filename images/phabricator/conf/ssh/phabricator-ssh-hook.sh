#!/bin/sh
VCSUSER="git"
ROOT="/srv/phabricator"

if [ "$1" != "$VCSUSER" ]; then
    exit 1
fi

exec "$ROOT/bin/ssh-auth" $@

