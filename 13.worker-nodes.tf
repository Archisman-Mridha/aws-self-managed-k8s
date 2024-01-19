resource "aws_launch_template" "worker_node" {
  name_prefix = "worker-node"

  image_id      = var.args.ami_id
  instance_type = "t4g.small"

  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.k8s_cluster.id]

  user_data = filebase64("${path.module}/outputs/kubeadm-join.as-worker.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      "node-type" = "worker"
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
}
