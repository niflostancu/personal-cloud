#!/bin/bash
#
# Runs some preliminary checks before starting the main services.
#

# 1. Check permissions for Seafile's home directory
seafile-fix-perms.sh

# 2. Check whether seafile is correctly installed
chpst -u seafile seafile-init-upgrade.sh


