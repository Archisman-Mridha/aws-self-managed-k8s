locals {
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

  cluster_name = "test"
  vpc_cidr     = "10.0.0.0/16"

  // 1 private subnet in each AZ + 1 public subnets in the first AZ.
  subnet_count = length(local.availability_zones) + 1

  master_node_count = length(local.availability_zones)
}
