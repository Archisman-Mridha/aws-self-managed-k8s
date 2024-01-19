resource "null_resource" "fetch_kubeadm_join_script" {
  provisioner "local-exec" {
    command = <<-EOC

      chmod 400 ${path.module}/outputs/private-key.pem

      scp \
        -i ${path.module}/outputs/private-key.pem \
        -o "ProxyCommand ssh ubuntu@${aws_instance.bastian_host.public_ip} -W %h:%p -i ${path.module}/outputs/private-key.pem" \
        ubuntu@${aws_instance.master_nodes[0].private_ip}:kubeadm-join.as-master.sh \
        ${path.module}/outputs/kubeadm-join.as-master.sh

      scp \
        -i ${path.module}/outputs/private-key.pem \
        -o "ProxyCommand ssh ubuntu@${aws_instance.bastian_host.public_ip} -W %h:%p -i ${path.module}/outputs/private-key.pem" \
        ubuntu@${aws_instance.master_nodes[0].private_ip}:kubeadm-join.as-worker.sh \
        ${path.module}/outputs/kubeadm-join.as-worker.sh

    EOC
  }

  depends_on = [null_resource.bootstrap_first_master_node]
}
