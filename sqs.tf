resource "aws_sqs_queue" "sqs_queue" {
  name   = var.webhook_name
  tags   = var.tags
  policy = aws_iam_policy_document.sqs_policy.json
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage*",
    ]
    resources = [aws_api_gateway_rest_api.webhook_api.arn]
  }
}
