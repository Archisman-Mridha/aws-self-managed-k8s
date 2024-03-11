# Bootstrapping a highly available self managed K8s cluster in AWS

This repository demonstrates how to bootstrap a highly available self managed Kubernetes cluster in AWS using Kubeadm.

> If you are looking for a production grade tool to provision self managed Kubernetes clusters, you can check out [Claudie](https://github.com/berops/claudie). It is open source and can provision multi-cloud and hybrid-cloud Kubernetes clusters (without using Kubernetes Cluster Federation).

## How to run

> Don't forget to create the `ami/variables.auto.pkrvars.hcl` and `terraform.tfvars.hcl` files.

First of all, create the `custom AMI (Amazon Machine Image)` using Hashicorp Packer, by executing this command :
```sh
cd ami && \
  packer init . && \
  packer build .
```

After the AMI is built and becomes active, Packer will output the AMI id. That'll be the value of `args.ami_id` in the Terraform module.

After provisioning everything, the Terraform module outputs :

- Public IP address of the Bastian Host
- Private IP addresses of the master nodes
- DNS name of the internal AWS ELB sitting in front of the master nodes

You will also find the `kubeconfig.yaml` and `private-key.pem` (contains SSH private key) files at _/outputs_.

To access the Kubernetes cluster, SSH into the Bastian Host using this command -
```sh
chmod 0400 ./outputs/private-key.pem
ssh -i ./outputs/private-key.pem ubuntu@bastian_host_public_ip

chmod 0400 private-key.pem
ssh -i private-key.pem ubuntu@first_master_node_private_ip
```

Then from the Bastian Host, SSH into the first master node. You can then access the Kubernetes cluster using `kubectl`.

## References

- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
- AWS Docs
