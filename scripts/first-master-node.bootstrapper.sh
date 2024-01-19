#!/bin/bash

# Causes the shell to treat unset variables as errors and exit immediately
set -o nounset

# Initialize Kubeadm
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --control-plane-endpoint ${KUBE_API_PUBLIC_ENDPOINT}:6443 \
  --upload-certs

# Placing kubeconfig file in ~/.kube/config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico (CNI plugin)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml &&
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml

# Store 'kubeadm join' (as master / worker) commands in files.
echo sudo $(sudo kubeadm token create --print-join-command) --control-plane --certificate-key $(sudo kubeadm init phase upload-certs --upload-certs | grep -vw -e certificate -e Namespace) >>kubeadm-join.as-master.sh
echo sudo $(kubeadm token create --print-join-command) >kubeadm-join.as-worker.sh
