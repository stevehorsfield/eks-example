terraform {}

provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access-key}"
  secret_key = "${var.secret-key}"

  version = "~> 2.0"
}

data "aws_region" "this" { }
data "aws_caller_identity" "this" { }