resource "aws_eks_cluster" "cluster" {
  name     = "${var.environment}-eks"
  role_arn = "${aws_iam_role.eks-cluster-control-plane.arn}"
  version  = "1.13"
  
  enabled_cluster_log_types = [ 
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_config {
    security_group_ids = [ "${aws_security_group.eks-cluster-control-plane.id}" ]
    subnet_ids         = [ "${var.eks-private-subnet-ids}" ]
    
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  provider = "aws.eks-creation"

  count = "${signum(var.eks-bootstrap["creator-role-exists"])}"

  depends_on = ["aws_cloudwatch_log_group.eks"]
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.environment}-eks/cluster"
  retention_in_days = 30
}
