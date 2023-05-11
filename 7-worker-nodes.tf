resource "null_resource" "fetch_kubeadm_join_script" {
  provisioner "local-exec" {
    command = <<-EOC

      chmod 400 ${path.module}/outputs/private-key.pem

      scp -i ${path.module}/outputs/private-key.pem \
        ubuntu@${aws_instance.master_node.public_ip}:kubeadm-join.sh \
        ${path.module}/outputs/kubeadm-join.sh

      echo -n "sudo " | cat - ${path.module}/outputs/kubeadm-join.sh > temp && mv temp ${path.module}/outputs/kubeadm-join.sh

    EOC
  }

  depends_on = [aws_instance.master_node]
}

resource "aws_instance" "worker_nodes" {
  count = length(var.aws_zones)

  subnet_id = aws_subnet.public_subnets[count.index].id
  vpc_security_group_ids = [
    aws_security_group.cluster.id
  ]

  ami           = data.aws_ami.ubuntu.image_id
  instance_type = var.aws_instance_type
  root_block_device {
    volume_size = 25
  }

  tags = {
    format("kubernetes.io/cluster/%v", local.cluster_name) = "owned"
  }

  key_name = aws_key_pair.keypair.key_name

  provisioner "remote-exec" {
    connection {
      host = self.public_ip

      user = "ubuntu"
      private_key = tls_private_key.private_key.private_key_pem
    }

    when = create
    on_failure = fail

    scripts = [
      "${path.module}/scripts/kubeadm-installer.sh",
      "${path.module}/outputs/kubeadm-join.sh"
    ]
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address
    ]
  }

  depends_on = [ null_resource.fetch_kubeadm_join_script ]
}