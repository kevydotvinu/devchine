#!/bin/bash
# This script edit sshd_config and restart sshd

echo "StreamLocalBindUnlink yes" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd
