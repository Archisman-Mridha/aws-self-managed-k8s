resource "null_resource" "fetch_kubeconfig" {
  provisioner "local-exec" {
    command = <<-EOC

      chmod 400 ${path.module}/outputs/private-key.pem

      scp \
        -i ${path.module}/outputs/private-key.pem \
        -o "ProxyCommand ssh ubuntu@${aws_instance.bastian_host.public_ip} -W %h:%p -i ${path.module}/outputs/private-key.pem" \
        ubuntu@${aws_instance.master_nodes[0].private_ip}:.kube/config \
        ${path.module}/outputs/kubeconfig.yaml

    EOC
  }

  depends_on = [null_resource.bootstrap_first_master_node]
}
