resource "null_resource" "fetch_files" {
  provisioner "local-exec" {
    command = <<-EOC

      ## --- Fetch 'kubeadm join' scripts. ---

      chmod 400 ${path.module}/outputs/private-key.pem

      rm -rf ${path.module}/outputs/kubeadm-join.as-master.sh ${path.module}/outputs/kubeadm-join.as-worker.sh

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

      cp ${path.module}/outputs/kubeadm-join.as-worker.sh ${path.module}/outputs/temp.txt

      cat <<EOF >${path.module}/outputs/kubeadm-join.as-worker.sh
      #cloud-boothook
      #!/bin/bash
      sudo systemctl restart containerd
      EOF

      echo $(cat ${path.module}/outputs/temp.txt) >> ${path.module}/outputs/kubeadm-join.as-worker.sh
      rm ${path.module}/outputs/temp.txt

      ## --- Fetch 'kubeconfig.yaml' file. ---

      scp \
        -i ${path.module}/outputs/private-key.pem \
        -o "ProxyCommand ssh ubuntu@${aws_instance.bastian_host.public_ip} -W %h:%p -i ${path.module}/outputs/private-key.pem" \
        ubuntu@${aws_instance.master_nodes[0].private_ip}:.kube/config \
        ${path.module}/outputs/kubeconfig.yaml

    EOC
  }

  depends_on = [null_resource.bootstrap_cluster]
}
