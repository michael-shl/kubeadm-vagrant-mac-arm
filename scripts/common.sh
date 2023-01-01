#!/bin/bash

# Common setup for all servers (Control Plane and Nodes)

set -euxo pipefail

# Variable Declaration

KUBERNETES_VERSION="1.23.15-00"

apt-get update && apt-get upgrade -y

apt-get install -y curl apt-transport-https ca-certificates gnupg2 software-properties-common uidmap

# disable swap
swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

# load the overlay kernel module, and the br_netfilter kernel module
modprobe overlay
modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF


cat /etc/sysctl.d/kubernetes.conf

sysctl --system

# Install containerd
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-get update -y
apt-get install containerd -y

### Install kubeadm.
### For more info, please see https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Download the Google Cloud public signing key:
mkdir -p /etc/apt/keyrings
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Provent the apt-get update failure issue
until apt update -y && apt -y upgrade && apt-get -y update
do
  apt clean
  apt-get clean
  sleep 2
  echo "Try again"
done

# Install kubeadm and kubelet and kubectl
apt-get install -y kubelet="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION" kubeadm="$KUBERNETES_VERSION"
apt-mark hold kubelet kubeadm kubectl

apt-get install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc

apt-get clean