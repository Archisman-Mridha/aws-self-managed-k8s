resource "aws_security_group" "node" {
  name = "node"

  vpc_id = aws_vpc.this.id

  // Establish full inter-connectivity between all the nodes.

  ingress {
    description = "Allow all inbound traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

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
