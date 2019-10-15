resource "aws_lambda_function" "eks-node-route53-registration" {
  function_name = "${var.environment}-eks-node-route53-registration"
  role          = "${aws_iam_role.eks-node-route53-registration.arn}"
  description   = "Update Route53 zone records to represent the full set of NodePort nodes"
  handler       = "eks-nodes-route53-lambda.lambda_handler"
  runtime       = "python2.7"

  filename         = "${data.archive_file.eks-node-route53-registration.output_path}"
  source_code_hash = "${data.archive_file.eks-node-route53-registration.output_base64sha256}"

  memory_size = 200
  timeout     = 60

  environment = {
    variables = {
      TARGET_VPC_ID     = "${var.vpc-id}"
      FORWARD_ZONE_ID   = "${var.dns-private-forward-zone-id}"
      FORWARD_DOMAIN    = "${var.dns-private-forward-zone-name}"
      ENTRY_SUBDOMAIN   = "eks-nodeport-nodes"
      ENTRY_TTL         = "300"
      SELECTOR_TAG      = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
      SELECTOR_VALUE    = "owned"
    }
  }

  tags {
    Environment = "${var.environment}"
    Name        = "${var.environment}-eks-node-route53-registration"
  }

  lifecycle {
    ignore_changes = [ "filename", "last_modified" ] # Filename is dynamically generated
  }
}

data "archive_file" "eks-node-route53-registration" {
  type        = "zip"
  source_file = "${path.module}/eks-nodes-route53-lambda.py"
  output_path = "${path.module}/eks-nodes-route53-lambda.zip"
}

resource "aws_cloudwatch_log_group" "eks-node-route53-registration" {
  name = "/aws/lambda/${aws_lambda_function.eks-node-route53-registration.function_name}"
}
