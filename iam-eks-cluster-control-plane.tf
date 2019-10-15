resource "aws_iam_role" "eks-cluster-control-plane" {
  name = "${var.environment}-eks-cluster-control-plane"
  assume_role_policy = "${data.aws_iam_policy_document.eks-cluster-control-plane-assume-role.json}"

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-eks-cluster-control-plane"
  }
}
  
data "aws_iam_policy_document" "eks-cluster-control-plane-assume-role" {
  statement {
    sid = "AllowAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [ "eks.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks-cluster-control-plane-aws-service-policy" {
  role       = "${aws_iam_role.eks-cluster-control-plane.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-control-plane-aws-cluster-policy" {
  role       = "${aws_iam_role.eks-cluster-control-plane.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
