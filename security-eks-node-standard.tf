resource "aws_security_group" "eks-cluster-node-standard" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.environment}-eks-cluster-node-standard"
  description = "Standard network security for most cluster nodes (incremental)"

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-eks-cluster-node-standard"
  }
}

resource "aws_security_group_rule" "eks-cluster-node-standard-ingress-https" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "Control plane access to HTTPS port"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  source_security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
}

resource "aws_security_group_rule" "eks-cluster-node-standard-ingress-proxy-ports" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "Control plane access to dynamic ports"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "1025"
  to_port           = "65535"
  
  source_security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
}

resource "aws_security_group_rule" "eks-cluster-node-standard-ingress-intra-complete-tcp" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "Intra-cluster full connectivity (required as also covers pods)"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "0"
  to_port           = "65535"
  self              = "true"
}

resource "aws_security_group_rule" "eks-cluster-node-standard-ingress-intra-complete-udp" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "Intra-cluster full connectivity (required as also covers pods)"
  type              = "ingress"
  protocol          = "udp"
  from_port         = "0"
  to_port           = "65535"
  self              = "true"
}

resource "aws_security_group_rule" "eks-cluster-node-standard-egress-intra-complete-tcp" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "Intra-cluster full connectivity (required as also covers pods)"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "0"
  to_port           = "65535"
  self              = "true"
}

resource "aws_security_group_rule" "eks-cluster-node-standard-egress-intra-complete-udp" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "Intra-cluster full connectivity (required as also covers pods)"
  type              = "egress"
  protocol          = "udp"
  from_port         = "0"
  to_port           = "65535"
  self              = "true"
}

resource "aws_security_group_rule" "eks-cluster-node-standard-egress-efs" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "NFS connectivity to EFS"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "2049" # NFS
  to_port           = "2049"
  cidr_blocks       = ["${var.vpc-cidr}"]
}

resource "aws_security_group_rule" "eks-cluster-node-standard-ingress-nodeport-alb-internal" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "Ingress for exposed services from internal ALB"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "30000"
  to_port           = "32767"

  source_security_group_id = "${aws_security_group.internal-ingress-alb.id}"
}

resource "aws_security_group_rule" "eks-cluster-node-standard-ingress-nodeport-alb-internal-mtu" {
  security_group_id = "${aws_security_group.eks-cluster-node-standard.id}"
  description       = "Ingress for MTU discovery from internal ALB"
  type              = "ingress"
  protocol          = "icmp"
  from_port         = "8"  # ICMP type number - Echo (8)
  to_port           = "-1" # ICMP code - not used in this case

  source_security_group_id = "${aws_security_group.internal-ingress-alb.id}"
}