resource "aws_instance" "master_nodes" {
  count = local.master_node_count

  subnet_id = aws_subnet.private_subnets[count.index].id

  vpc_security_group_ids = [
    aws_security_group.k8s_cluster.id
  ]

  ami           = var.args.ami_id
  instance_type = "t4g.small"
  root_block_device {
    volume_size = 25
  }

  key_name = aws_key_pair.this.key_name

  tags = {
    format("kubernetes.io/cluster/%v", local.cluster_name) = "owned"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

resource "aws_elb_attachment" "master_nodes" {
  count = local.master_node_count

  elb      = aws_elb.kube_api_server.id
  instance = aws_instance.master_nodes[count.index].id
}
