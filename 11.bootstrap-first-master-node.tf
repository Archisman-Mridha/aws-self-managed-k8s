resource "null_resource" "bootstrap_first_master_node" {
  provisioner "remote-exec" {
    connection {
      host = aws_instance.master_nodes[0].private_ip

      user        = "ubuntu"
      private_key = tls_private_key.this.private_key_pem

      bastion_host        = aws_instance.bastian_host.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = tls_private_key.this.private_key_pem
    }

    when       = create
    on_failure = fail

    inline = [
      file("${path.module}/scripts/prepare-node.sh"),
      templatefile(
        "${path.module}/scripts/first-master-node.bootstrapper.sh",
        {
          KUBE_API_PUBLIC_ENDPOINT : aws_elb.kube_api_server.dns_name
        }
      )
    ]
  }

  depends_on = [aws_elb_attachment.master_nodes]
}
