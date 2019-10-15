resource "aws_iam_role" "eks-cluster-owner" {
  name = "${var.environment}-eks-cluster-owner"
  assume_role_policy = "${data.aws_iam_policy_document.eks-cluster-owner-assume-role.json}"

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-eks-cluster-owner"
  }
}
  
data "aws_iam_policy_document" "eks-cluster-owner-assume-role" {
  statement {
    sid = "AllowAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "AWS"
      identifiers = [ 
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks-administration" {
  role       = "${aws_iam_role.eks-cluster-owner.name}"
  policy_arn = "${aws_iam_policy.eks-administration.arn}"
}

resource "aws_iam_policy" "eks-administration" {
  name   = "${var.environment}-eks-administration"
  path   = "/"
  policy = "${data.aws_iam_policy_document.eks-administration.json}"
}

data "aws_iam_policy_document" "eks-administration" {
  statement {
    sid = "AllowEKSManagement"
    effect = "Allow"
    actions = [
      "eks:*",
    ]
    resources = [
      "arn:aws:eks:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:cluster/${var.environment}-eks",
      "arn:aws:eks:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:cluster/${var.environment}-eks/*",
    ]
  }

  statement {
    sid = "AllowPassControlPlaneRole"
    effect = "Allow"
    actions = [ "iam:PassRole" ]
    resources = [
      "${aws_iam_role.eks-cluster-control-plane.arn}",
    ]
  }
}
