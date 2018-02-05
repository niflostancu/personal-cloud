#!/bin/sh

# do not detach (-D), log to stderr (-e), use specified config (-f)
exec /usr/sbin/sshd -f "/etc/ssh/sshd_phabricator" -D -e "$@"

