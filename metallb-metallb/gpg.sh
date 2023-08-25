#!/bin/bash
# This script edit sshd_config and restart sshd

if ! sudo grep 'StreamLocalBindUnlink' /etc/ssh/sshd_config; then
	echo "StreamLocalBindUnlink yes" | sudo tee -a /etc/ssh/sshd_config
	sudo systemctl restart sshd
fi
