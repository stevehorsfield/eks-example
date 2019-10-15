resource "aws_iam_role" "eks-node-route53-registration" {
  name = "${var.environment}-eks-node-route53-registration"
  assume_role_policy = "${data.aws_iam_policy_document.eks-node-route53-registration-assume-role.json}"

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-eks-node-route53-registration"
  }
}

resource "aws_iam_role_policy" "eks-node-route53-registration" {
  role = "${aws_iam_role.eks-node-route53-registration.name}"
  policy = "${data.aws_iam_policy_document.eks-node-route53-registration.json}"
}
  
data "aws_iam_policy_document" "eks-node-route53-registration-assume-role" {
  statement {
    sid = "AllowAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [ "lambda.amazonaws.com" ]
    }
  }
}

data "aws_iam_policy_document" "eks-node-route53-registration" {
  statement {
    sid    = "AllowRoute53Read"
    effect = "Allow"

    actions = [
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListHostedZonesByName",
    ]

    resources = ["*"]
  }

  statement {
    sid     = "AllowRoute53Modification"
    effect  = "Allow"
    actions = ["route53:ChangeResourceRecordSets"]

    resources = [
      "arn:aws:route53:::hostedzone/${var.dns-private-forward-zone-id}",
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogging"
    effect = "Allow"

    actions = [
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.eks-node-route53-registration.arn}",
      "${aws_cloudwatch_log_group.eks-node-route53-registration.arn}:*",
    ]
  }

  statement {
    sid       = "AllowEC2Discovery"
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}