resource "aws_security_group" "internal-ingress-alb" {
  vpc_id = "${varintegration.vpc-id}"
  name   = "${var.environment}-internal-ingress-alb"

  tags {
    Name        = "${var.environment}-internal-ingress-alb"
    Environment = "${var.environment}"
    Application = "internal-ingress"
  }
}

resource "aws_security_group_rule" "internal-ingress-alb-outbound-nodeport" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to Kubernetes NodePort services"
  type              = "egress"
  from_port         = "30000"
  to_port           = "32767"
  protocol          = "tcp"

  source_security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
}

resource "aws_security_group_rule" "internal-ingress-alb-outbound-http" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to HTTP ports on instances etc."
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"

  source_security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
}

resource "aws_security_group_rule" "internal-ingress-alb-outbound-https" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to HTTP ports on instances etc."
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"

  source_security_group_id = "${aws_security_group.eks-cluster-node-base.id}"
}

resource "aws_security_group_rule" "internal-ingress-alb-inbound-http" {
  security_group_id = "${aws_security_group.internal-ingress-alb.id}"
  description       = "Allow access to HTTP ports on instances etc."
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["${var.internal-alb-cidr-blocks}"]
}