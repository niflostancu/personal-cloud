#!/bin/bash
# checks whether the SSH host keys are generated and generates them if not

set -e

SSH_KEYS_PATH="/etc/ssh/keys"

if [[ ! -f "$SSH_KEYS_PATH/ssh_host_rsa_key" ]]; then
	echo "Host keys not found, regenerating them..."
	ssh-keygen -A
	/bin/cp -vf /etc/ssh/ssh_host_{dsa_,ecdsa_,ed25519_,rsa_}key{,.pub} "$SSH_KEYS_PATH/"
fi

/bin/cp -f "$SSH_KEYS_PATH/"ssh_host_* "/etc/ssh/"

chown -R root:root "/etc/ssh"
chmod -R 600 "/etc/ssh"

exit 0

