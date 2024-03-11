resource "aws_elb" "kube_api_server" {
  subnets = [for subnet in aws_subnet.private_subnets : subnet.id]

  security_groups = [aws_security_group.elb.id]

  listener {
    lb_port     = 6443
    lb_protocol = "TCP"

    instance_port     = 6443
    instance_protocol = "TCP"
  }

  internal                  = true
  cross_zone_load_balancing = true

  // The time in seconds that the connection is allowed to be idle.
  idle_timeout = 60

  connection_draining = false

  health_check {
    target = "TCP:6443"

    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5

    interval = 10
  }
}

resource "aws_security_group" "elb" {
  name_prefix = "elb"

  vpc_id = aws_vpc.this.id

  ingress {
    description = "Allow all inbound traffic"

    from_port = 6443
    to_port   = 6443
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
