resource "aws_lb" "internal-ingress" {
  name                       = "${var.environment}-internal-ingress"
  internal                   = true
  load_balancer_type         = "application"
  enable_deletion_protection = false
  idle_timeout               = 300
  enable_http2               = true
  ip_address_type            = "ipv4"
  subnets                    = [ "${var.alb-private-subnet-ids}" ]
  security_groups            = [ "${aws_security_group.internal-ingress-alb.id}" ]

  tags {
    Name        = "${var.environment}-internal-ingress"
    Environment = "${var.environment}"
  }
}

# HTTP listener on 80
resource "aws_lb_listener" "internal-ingress-http" {
  load_balancer_arn = "${aws_lb.internal-ingress.arn}"
  protocol          = "HTTP"

  port              = 80

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 - Not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "internal-ingress-dynamic-http" {
  listener_arn = "${aws_lb_listener.internal-ingress-http.arn}"

  priority = 1000
  
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal-ingress-dynamic.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.dynamic-ingress["host-name-match"]}"]
  }
}

resource "aws_lb_target_group" "internal-ingress-dynamic" {
  name        = "${var.environment}-int-dynamic"
  protocol    = "HTTP"
  port        = "${var.dynamic-ingress["port"]}"
  target_type = "instance"
  vpc_id      = "${var.vpc-id}"

  deregistration_delay = 300

  health_check {
    interval            = 30
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}
