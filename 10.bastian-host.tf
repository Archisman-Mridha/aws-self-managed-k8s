resource "aws_instance" "bastian_host" {
  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.bastian_host.id
  ]

  ami           = data.aws_ami.amazon_linux_2.image_id
  instance_type = "t4g.small"
  root_block_device {
    volume_size = 25
  }

  key_name = aws_key_pair.this.key_name

  provisioner "file" {
    when       = create
    on_failure = fail

    connection {
      host = aws_instance.bastian_host.public_ip

      user        = "ubuntu"
      private_key = tls_private_key.this.private_key_pem
    }

    content     = tls_private_key.this.private_key_pem
    destination = "/home/ubuntu/private-key.pem"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
      associate_public_ip_address
    ]
  }
}
