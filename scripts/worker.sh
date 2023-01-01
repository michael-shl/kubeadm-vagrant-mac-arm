#!/bin/bash

set -euxo pipefail
NODENAME=$(hostname -s)
config_path="/vagrant/configs"

# Add k8scp host entry in the local hosts file
cat $config_path/k8scp-host-entry >> /etc/hosts

mkdir -p "$HOME"/.kube
cp $config_path/config "$HOME"/.kube/

/bin/bash $config_path/join.sh -v

sudo -i -u vagrant bash << EOF
whoami
mkdir -p /home/vagrant/.kube
sudo cp -i $config_path/config /home/vagrant/.kube/
sudo chown "$(id -u vagrant)":"$(id -g vagrant)"  /home/vagrant/.kube/config
EOF
