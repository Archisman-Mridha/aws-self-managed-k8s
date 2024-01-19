resource "aws_instance" "master_nodes" {
  count = length(local.master_nodes)

  subnet_id = local.availability_zone_subnet_id_map[local.master_nodes[count.index].az]

  vpc_security_group_ids = [
    aws_security_group.k8s_cluster.id
  ]

  ami           = data.aws_ami.amazon_linux_2.image_id
  instance_type = local.master_nodes[count.index].instance_type
  root_block_device {
    volume_size = 25
  }

  tags = {
    format("kubernetes.io/cluster/%v", var.args.cluster_name) = "owned"
  }

  key_name = aws_key_pair.this.key_name

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_instance" "worker_nodes" {
  count = length(local.worker_nodes)

  subnet_id = local.availability_zone_subnet_id_map[local.worker_nodes[count.index].az]

  vpc_security_group_ids = [
    aws_security_group.k8s_cluster.id
  ]

  ami           = data.aws_ami.amazon_linux_2.image_id
  instance_type = local.worker_nodes[count.index].instance_type
  root_block_device {
    volume_size = 25
  }

  tags = {
    format("kubernetes.io/cluster/%v", var.args.cluster_name) = "owned"
  }

  key_name = aws_key_pair.this.key_name

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}
