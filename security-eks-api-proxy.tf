resource "aws_security_group" "eks-cluster-api-proxy" {
  vpc_id      = "${var.vpc-id}"
  name        = "${var.environment}-eks-cluster-api-proxy"
  description = "Allows extra-VPC access to the cluster API servers via a proxy node"

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-eks-cluster-api-proxy"
  }
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-https-control-plane" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "HTTPS to control plane"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  source_security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-http-internet" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "HTTP to Internet"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  
  cidr_blocks = [ "0.0.0.0/0" ] # Hard to filter this, required for Amazon Linux security updates
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-https-internet" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "HTTPS to Internet"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  cidr_blocks = [ "0.0.0.0/0" ] # Hard to filter this, required for AWS EKS APIs
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-dns-tcp" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "DNS TCP"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "53"
  to_port           = "53"
  
  cidr_blocks = [ "${var.dns-cidrs}" ]
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-dns-udp" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "DNS TCP"
  type              = "egress"
  protocol          = "udp"
  from_port         = "53"
  to_port           = "53"
  
  cidr_blocks = [ "${var.dns-cidrs}" ]
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-ntp-udp" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "NTP UDP"
  type              = "egress"
  protocol          = "udp"
  from_port         = "123"
  to_port           = "123"
  
  cidr_blocks = [ "${var.ntp-cidrs}" ]
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-ntp-tcp" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "NTP TCP"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "123"
  to_port           = "123"
  
  cidr_blocks = [ "${var.ntp-cidrs}" ]
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-external-access" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "Proxy access from internal network"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  cidr_blocks       = ["${var.eks-api-proxy-access-source-cidrs}"]
}

resource "aws_security_group_rule" "eks-cluster-api-proxy-ssh-access" {
  security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
  description       = "Proxy access from internal network"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  
  cidr_blocks       = ["${var.ssh-source-cidrs}"]
}
