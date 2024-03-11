variable "args" {
  type = object({

    credentials = object({
      access_key = string
      secret_key = string
    })

    ami_id = string
  })
}

locals {
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  // 1 private subnet in each AZ + 1 public subnets in the first AZ.
  subnet_count = length(local.availability_zones) + 1

  cluster_name      = "test"
  master_node_count = length(local.availability_zones)
}

output "outputs" {
  value = {
    kube_api_server_dns_name = aws_elb.kube_api_server.dns_name

    bastian_host_public_ip  = aws_instance.bastian_host.public_ip
    master_nodes_private_ip = aws_instance.master_nodes.*.private_ip
  }
}
