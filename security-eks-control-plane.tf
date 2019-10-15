resource "aws_security_group" "eks-cluster-control-plane" {
  vpc_id      = "${var.vpc-id}"
  name        = "${var.environment}-eks-control-plane"
  description = "EKS control plane security (from inside cluster only)"

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-eks-cluster-control-plane"
  }
}

resource "aws_security_group_rule" "eks-cluster-control-plane-standard-egress-https" {
  security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
  description       = "Control plane access to API extensions running in the cluster"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  source_security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
}

resource "aws_security_group_rule" "eks-cluster-control-plane-standard-ingress-https" {
  security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
  description       = "Node access to control plane HTTPS"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  source_security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
}

resource "aws_security_group_rule" "eks-cluster-control-plane-api-proxy-ingress-https" {
  security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
  description       = "API proxy access to control plane HTTPS"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  
  source_security_group_id = "${aws_security_group.eks-cluster-api-proxy.id}"
}

resource "aws_security_group_rule" "eks-cluster-control-plane-proxy-ports" {
  security_group_id = "${aws_security_group.eks-cluster-control-plane.id}"
  description       = "Control plane access to dynamic ports"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "1025"
  to_port           = "65535"
  
  source_security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
}