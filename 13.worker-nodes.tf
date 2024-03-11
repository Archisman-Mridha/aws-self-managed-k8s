/* resource "aws_launch_template" "worker_node" {
  name_prefix = "worker-node"

  image_id      = var.args.ami_id
  instance_type = "t4g.small"

  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.node.id]

  user_data = filebase64("${path.module}/outputs/kubeadm-join.as-worker.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      KubernetesCluster                                      = local.cluster_name
      format("kubernetes.io/cluster/%v", local.cluster_name) = "1"
      "node-type"                                            = "worker"
    }
  }
}

resource "aws_autoscaling_group" "worker_nodes" {
  name_prefix = "worker-nodes"

  launch_template {
    id = aws_launch_template.worker_node.id
  }

  vpc_zone_identifier = [for private_subnet in aws_subnet.private_subnets[*] : private_subnet.id]

  min_size = 1
  max_size = 3
} */

resource "aws_instance" "worker_nodes" {
  count = local.master_node_count

  subnet_id = aws_subnet.private_subnets[(count.index % length(local.availability_zones))].id

  vpc_security_group_ids = [
    aws_security_group.node.id
  ]

  ami           = var.args.ami_id
  instance_type = "t4g.small"
  root_block_device {
    volume_size = 25
  }

  key_name = aws_key_pair.this.key_name

  provisioner "remote-exec" {
    connection {
      host = self.private_ip

      user        = "ubuntu"
      private_key = tls_private_key.this.private_key_pem

      bastion_host        = aws_instance.bastian_host.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = tls_private_key.this.private_key_pem
    }

    when       = create
    on_failure = fail

    scripts = [
      "${path.module}/outputs/kubeadm-join.as-worker.sh"
    ]
  }

  tags = {
    KubernetesCluster                                      = local.cluster_name
    format("kubernetes.io/cluster/%v", local.cluster_name) = "1"
    "node-type"                                            = "worker"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }

  depends_on = [null_resource.bootstrap_cluster]
}
