resource "aws_cloudwatch_event_rule" "eks-node-route53-registration" {
  name        = "${var.environment}-eks-node-route53-registration"
  description = "Triggers Lambda on schedule to update DNS registration for EKS nodes"
  is_enabled  = true

  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = "${aws_cloudwatch_event_rule.eks-node-route53-registration.name}"
  target_id = "SendToLambda"
  arn       = "${aws_lambda_function.eks-node-route53-registration.arn}"
}

resource "aws_lambda_permission" "eks-node-route53-registration-trigger" {
  function_name = "${aws_lambda_function.eks-node-route53-registration.function_name}"
  statement_id  = "AllowTriggerFromCloudWatchEvents"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.eks-node-route53-registration.arn}"
  action        = "lambda:InvokeFunction"

  depends_on = ["aws_lambda_function.eks-node-route53-registration"]
}
