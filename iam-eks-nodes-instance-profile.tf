resource "aws_iam_instance_profile" "eks-nodes" {
  name = "${var.environment}-eks-node"
  role = "${aws_iam_role.eks-nodes.id}"
}

resource "aws_iam_role" "eks-nodes" {
  name               = "${var.environment}-eks-node"
  assume_role_policy = "${data.aws_iam_policy_document.eks-nodes-assume.json}"
}

resource "aws_iam_role_policy" "eks-nodes" {
  role   = "${aws_iam_role.eks-nodes.id}"
  policy = "${data.aws_iam_policy_document.eks-nodes.json}"
}

data "aws_iam_policy_document" "eks-nodes-assume" {
  statement {
    sid = "AllowEC2Assume"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


/* Reference:
        - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
        - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
        - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly (Kubelet requires this!)

  https://github.com/awslabs/amazon-eks-ami/blob/master/amazon-eks-nodegroup.yaml#L307-L309        
*/
data "aws_iam_policy_document" "eks-nodes" {
  statement {
    sid = "AllowDiscoveryOfEC2Resources"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:DescribeVpcs",
      "eks:DescribeCluster"
    ]
    resources = ["*"] # Filtering is not supported
  }
  statement {
    sid = "AllowDiscoveryofEKSCluster"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster"
    ]
    resources = [
      "arn:aws:eks:us-east-1:*:cluster/${aws_eks_cluster.cluster.name}"
    ]
  }
  statement {
    sid = "AllowCNIDiscoveryActions"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
    ]
    resources = ["*"] # Filtering is not supported
  }
  statement {
    sid = "AllowCNIModificationActions" # Not possible to restrict by VPC
    effect = "Allow"
    actions = [
      "ec2:AssignPrivateIpAddresses",
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:UnassignPrivateIpAddresses"
    ]
    resources = ["*"] # Filtering is not supported
  }
  statement {
    sid = "AllowCNITagCreationOnNetworkInterfaces" # Not possible to restrict by VPC
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
    ]
    resources = [
      "arn:aws:ec2:${data.aws_region.this.name}:*:network-interface/*"
    ]
  }
  statement {
    sid = "AllowECRAccess" # Required by kubelet
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowDownloadSoftwareAndConfig"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion",
    ]
    resources = [
      "arn:aws:s3:::${var.software-bucket}/*",
      "${aws_s3_bucket.system-configuration.arn}/node-exporter/*",
      "${aws_s3_bucket.system-configuration.arn}/update-auto-reboot/*",
    ]
  }

  statement {
    sid = "AllowListSoftwareAndConfigBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.software-bucket}/*",
      "${aws_s3_bucket.system-configuration.arn}"
    ]
  }
}