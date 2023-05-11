resource "aws_instance" "master_node" {

  subnet_id = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [
    aws_security_group.cluster.id
  ]

  ami           = data.aws_ami.ubuntu.image_id
  instance_type = var.aws_instance_type
  root_block_device {
    volume_size = 25
  }

  tags = {
    // Kubernetes uses tags to identify EC2 instances that it can use to schedule pods.
    // So this tag is compulsary.
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

    inline = [
      file("${path.module}/scripts/kubeadm-installer.sh"),
      templatefile(
        "${path.module}/scripts/master-node.bootstrapper.sh",
        {
          KUBE_API_PUBLIC_ENDPOINT: self.public_ip
        }
      )
    ]
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address
    ]
  }
}

resource "null_resource" "fetch_kubeconfig" {
  provisioner "local-exec" {
    command = <<-EOC

      chmod 400 ${path.module}/outputs/private-key.pem

      scp -i ${path.module}/outputs/private-key.pem \
        ubuntu@${aws_instance.master_node.public_ip}:.kube/config \
        ${path.module}/outputs/kubeconfig.yaml

    EOC
  }

  depends_on = [aws_instance.master_node]
}