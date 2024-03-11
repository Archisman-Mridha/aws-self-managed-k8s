data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

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

resource "aws_security_group" "bastian_host" {
  name_prefix = "bastian-host"

  vpc_id = aws_vpc.this.id

  // In production scenarios, the Bastian Host can be accessed, only from the IPs that you've
  // allowed. But for simplicity, I am keeping it accessible from anywhere.
  ingress {
    description = "Allow access from anywhere"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}
