# Support bootstrapping
locals {
  provider-aws-eks-cluster-owner-role-list      = "${signum(var.eks-bootstrap["creator-role-exists"]) == 1 ? join(",",aws_iam_role.eks-cluster-owner.*.arn) : ""}"
  provider-aws-eks-cluster-owner-effective-role = "${element(split(",",local.provider-aws-eks-cluster-owner-role-list),0)}"
}

provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access-key}"
  secret_key = "${var.secret-key}"

  version = "~> 2.0"

  assume_role {
    role_arn = "${local.provider-aws-eks-cluster-owner-effective-role}"
  }

  alias = "eks-creation"
}
