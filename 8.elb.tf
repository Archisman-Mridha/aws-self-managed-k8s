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
