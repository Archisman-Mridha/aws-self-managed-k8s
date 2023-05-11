#!/bin/bash

# Redirects both standard output (stdout) and standard error (stderr) streams to the specified file
exec &>/var/log/kubeadm-installer.log

set -o verbose
set -o errexit
# Causes bash to exit with a non-zero status if any command in a pipeline fails, instead of the default behavior which is to
# only exit with the status of the last command in the pipeline.
set -o pipefail

# Install ContainerD
wget https://github.com/containerd/containerd/releases/download/v1.7.1/containerd-1.7.1-linux-amd64.tar.gz &&
  sudo tar Cxzvf /usr/local containerd-1.7.1-linux-amd64.tar.gz
# Start ContainerD using SystemD
sudo mkdir -p /usr/local/lib/systemd/system &&
  sudo wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -O /usr/local/lib/systemd/system/containerd.service &&
  sudo systemctl daemon-reload &&
  sudo systemctl enable --now containerd
# Install runC
wget https://github.com/opencontainers/runc/releases/download/v1.1.7/runc.amd64 &&
  sudo install -m 755 runc.amd64 /usr/local/sbin/runc
# Install CNI plugins
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz &&
  sudo mkdir -p /opt/cni/bin &&
  sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz
# Configure ContainerD
sudo mkdir -p /etc/containerd &&
  containerd config default > config.toml &&
  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' config.toml &&
  sudo mv config.toml /etc/containerd/config.toml
# Restart ContainerD
sudo systemctl restart containerd

# Install Kubernetes components
sudo apt-get update &&
  sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg &&
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list &&
  sudo apt-get update &&
  sudo apt-get install -y kubelet kubeadm kubectl &&
  sudo apt-mark hold kubelet kubeadm kubectl

# Forwarding IPv4 and letting iptables see bridged traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay &&
  sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
  net.bridge.bridge-nf-call-iptables  = 1
  net.bridge.bridge-nf-call-ip6tables = 1
  net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Cleanup
rm cni-plugins-linux-amd64-v1.3.0.tgz containerd-1.7.1-linux-amd64.tar.gz runc.amd64