resource "aws_security_group" "eks-cluster-node-base" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.environment}-eks-cluster-node-base"
  description = "Minimum network security for cluster nodes to operate"

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-eks-cluster-node-base"
  }
}

resource "aws_security_group_rule" "eks-cluster-node-base-ssh" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "SSH to nodes"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = ["${var.ssh-source-cidrs}"]
}

resource "aws_security_group_rule" "eks-cluster-node-base-https-control-plane" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "HTTPS to control plane"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  source_security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
}

resource "aws_security_group_rule" "eks-cluster-node-base-http-internet" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "HTTP to Internet"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  
  cidr_blocks = [ "0.0.0.0/0" ] # Hard to filter this, required access to Amazon Linux yum repositories
}

resource "aws_security_group_rule" "eks-cluster-node-base-https-internet" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "HTTPS to Internet"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  cidr_blocks = [ "0.0.0.0/0" ] # Hard to filter this, required for AWS EKS APIs
}

resource "aws_security_group_rule" "eks-cluster-node-base-dns-coredns-ingress-udp" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "CoreDNS UDP ingress"
  type              = "ingress"
  protocol          = "udp"
  from_port         = "53"
  to_port           = "53"
  self              = true
}

resource "aws_security_group_rule" "eks-cluster-node-base-dns-coredns-ingress-tcp" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "CoreDNS TCP ingress"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "53"
  to_port           = "53"
  self              = true
}


resource "aws_security_group_rule" "eks-cluster-node-base-dns-tcp" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "DNS TCP"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "53"
  to_port           = "53"
  
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "eks-cluster-node-base-dns-udp" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "DNS UDP"
  type              = "egress"
  protocol          = "udp"
  from_port         = "53"
  to_port           = "53"
  
  cidr_blocks = [ "0.0.0.0/0" ] # Necessary to support full EKS node requirements
}

resource "aws_security_group_rule" "eks-cluster-node-base-ntp-udp" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "NTP UDP"
  type              = "egress"
  protocol          = "udp"
  from_port         = "123"
  to_port           = "123"
  
  cidr_blocks = [ "${var.ntp_cidrs}" ]
}

resource "aws_security_group_rule" "eks-cluster-node-base-ntp-tcp" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "NTP TCP"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "123"
  to_port           = "123"
  
  cidr_blocks = [ "${var.ntp_cidrs}" ]
}

resource "aws_security_group_rule" "eks-cluster-node-base-kubelet-control-plane" {
  security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
  description       = "Kubelet management from control plane"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "10250"
  to_port           = "10250"
  
  source_security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
}
