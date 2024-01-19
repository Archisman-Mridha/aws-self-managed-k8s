output "bastian_host_public_ip" {
  value = aws_instance.bastian_host.public_ip
}

output "master_nodes_private_ip" {
  value = aws_instance.master_nodes.*.private_ip
}

output "kube_api_server_dns_name" {
  value = aws_elb.kube_api_server.dns_name
}
