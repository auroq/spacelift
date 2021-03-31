resource "aws_iam_role" "cloudwatch" {
  name               = "api-gateway-cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role_policy_document.json
}

data "aws_iam_policy_document" "cloudwatch_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_global_apigateway" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}