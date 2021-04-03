resource "aws_iam_role" "spacelift_role" {
  name               = var.aws_role_name
  assume_role_policy = data.aws_iam_policy_document.spacelift_assume_role_policy.json
}

data "aws_iam_policy_document" "spacelift_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com",
        "lambda.amazonaws.com",
        "dynamodb.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "spacelift_cloudwatch" {
  role       = aws_iam_role.spacelift_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "spacelift_dynamodb" {
  role   = aws_iam_role.spacelift_role.name
  policy_arn = aws_iam_policy.spacelift_dynamodb.arn
}

resource "aws_iam_policy" "spacelift_dynamodb" {
  name = "${var.aws_role_name}.dynamodb"
  policy = data.aws_iam_policy_document.spacelift_dynamodb.json
}

data "aws_iam_policy_document" "spacelift_dynamodb" {
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
      "dynamodb:PutItem"
    ]
    resources = [
      aws_dynamodb_table.webhook_database.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "spacelift_lambda" {
  role   = aws_iam_role.spacelift_role.name
  policy_arn = aws_iam_policy.spacelift_lambda.arn
}

resource "aws_iam_policy" "spacelift_lambda" {
  name = "${var.aws_role_name}-lambda"
  policy = data.aws_iam_policy_document.spacelift_lambda.json
}

data "aws_iam_policy_document" "spacelift_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [aws_lambda_function.lambda_integration.arn]
  }
}
