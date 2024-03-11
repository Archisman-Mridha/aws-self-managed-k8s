#!/bin/bash

# Causes the shell to treat unset variables as errors and exit immediately
set -o nounset

# Initialize Kubeadm
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --control-plane-endpoint ${KUBE_API_PUBLIC_ENDPOINT}:6443 \
  --upload-certs \
  --skip-phases=addon/kube-proxy

# Placing kubeconfig file in ~/.kube/config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Store 'kubeadm join' (as master / worker) commands in files.
echo sudo $(sudo kubeadm token create --print-join-command) --control-plane --certificate-key $(sudo kubeadm init phase upload-certs --upload-certs | grep -vw -e certificate -e Namespace) >>kubeadm-join.as-master.sh
echo sudo $(kubeadm token create --print-join-command) >>kubeadm-join.as-worker.sh

## --- Install Cilium (CNI) ---

sudo snap install helm --classic

helm repo add cilium https://helm.cilium.io/

cat <<EOF >cilium.helm-values.yaml
kubeProxyReplacement: true
k8sServiceHost: ${KUBE_API_PUBLIC_ENDPOINT}
k8sServicePort: 6443

hubble:
  relay:
    enabled: true
  ui:
    enabled: true
EOF

helm install cilium cilium/cilium --version 1.16.0-pre.0 \
  -n cilium --create-namespace \
  --values cilium.helm-values.yaml
