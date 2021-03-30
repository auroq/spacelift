resource "aws_iam_role" "spacelift_webhook" {
  name               = var.aws_role_name
  assume_role_policy = data.aws_iam_policy_document.spacelift_assume_role_policy.json
}

data "aws_iam_policy_document" "spacelift_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "dynamodb.amazonaws.com",
        "apigateway.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "spacelift_webhook_cloudwatch_managed" {
  role       = aws_iam_role.spacelift_webhook.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy" "spacelift_webhook_dynamodb" {
  name   = "spacelift-webhook-dynamodb"
  role   = aws_iam_role.spacelift_webhook.name
  policy = data.aws_iam_policy_document.spacelift_webhook_dynamodb.json
}

data "aws_iam_policy_document" "spacelift_webhook_dynamodb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:List*",
      "dynamodb:DescribeReservedCapacity*",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWrite*",
      "dynamodb:CreateTable",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    resources = [
      aws_dynamodb_table.spacelift_webhook.arn
    ]
  }
}
