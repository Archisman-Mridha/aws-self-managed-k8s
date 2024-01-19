resource "null_resource" "bootstrap_remaining_master_nodes" {
  count = length(aws_instance.master_nodes) - 1

  provisioner "remote-exec" {
    connection {
      host = aws_instance.master_nodes[1 + count.index].private_ip

      user        = "ubuntu"
      private_key = tls_private_key.this.private_key_pem

      bastion_host        = aws_instance.bastian_host.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = tls_private_key.this.private_key_pem
    }

    when       = create
    on_failure = fail

    scripts = [
      "${path.module}/scripts/prepare-node.sh",
      "${path.module}/outputs/kubeadm-join.as-master.sh"
    ]
  }

  depends_on = [null_resource.fetch_kubeadm_join_script]
}
