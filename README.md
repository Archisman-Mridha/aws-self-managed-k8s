# Bootstrapping a self managed K8s cluster in AWS

This repository demonstrates how to create a self managed Kubernetes cluster in AWS using Kubeadm.

After provisioning everything, the Terraform module outputs :

- Public IP address of the Bastian Host
- Private IP addresses of the master nodes
- DNS name of the internal AWS ELB sitting in front of the master nodes

You will also find the `kubeconfig.yaml` and `private-key.pem` (contains SSH private key) files at _/outputs_.

## How to access the Kubernetes cluster

SSH into the Bastian Host using this command -

```sh
ssh -i ./outputs/private-key.pem ubuntu@bastian_host_public_ip
chmod 0400 private-key.pem
```

Then from the Bastian Host, SSH into the first master node.

You can now access the Kubernetes cluster using `kubectl` 🙂.

## Shoutout

Open Source projects using which you can provision production grade self-managed Kubernetes clusters :

- [Claudie](https://github.com/berops/claudie) - Can provision a single multi-cloud Kubernetes cluster.
- [kOps](https://github.com/kubernetes/kops)

## References

- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
- AWS Docs
