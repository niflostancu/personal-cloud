#!/bin/bash
git clone --depth 1 -b stable https://github.com/phacility/libphutil.git /srv/libphutil
git clone --depth 1 -b stable https://github.com/phacility/arcanist.git /srv/arcanist
git clone --depth 1 -b stable https://github.com/phacility/phabricator.git /srv/phabricator

chmod 755 /srv/libphutil
chmod 755 /srv/arcanist
chmod 755 /srv/phabricator

cp -a "/srv/phabricator/conf" "/srv/phabricator/conf.orig"
chown -R phabricator:phabricator /srv/phabricator/conf.orig

mkdir -p /var/tmp/phd/pid
mkdir -p /var/tmp/phd/log
chown -R phabricator:phabricator /var/tmp/phd

