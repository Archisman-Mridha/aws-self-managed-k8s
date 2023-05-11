export kube_api_public_endpoint=${KUBE_API_PUBLIC_ENDPOINT}

# Causes the shell to treat unset variables as errors and exit immediately
set -o nounset

# Initialize Kubeadm
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --control-plane-endpoint $kube_api_public_endpoint:6443

# Placing kubeconfig file in ~/.kube/config
mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml &&
  kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml

# Get the Kubeadm join command
sudo kubeadm token create --print-join-command > kubeadm-join.sh