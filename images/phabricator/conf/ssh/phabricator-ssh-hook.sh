#!/bin/bash
PHB_ROOT="/srv/phabricator"

[[ "$1" != "git" ]] && exit 1

exec "$PHB_ROOT/bin/ssh-auth" $@

