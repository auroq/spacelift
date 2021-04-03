resource "aws_api_gateway_account" "api_gateway_cloudwatch_role" {
  cloudwatch_role_arn = aws_iam_role.spacelift_role.arn
}

resource "aws_api_gateway_rest_api" "webhook_api" {
  name        = var.webhook_name
  description = "API Gateway for accepting webhooks from Spacelift"
  tags = var.tags
}

resource "aws_api_gateway_method" "webhook_post" {
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  resource_id   = aws_api_gateway_rest_api.webhook_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "webhook_post_settings" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  stage_name  = aws_api_gateway_stage.webhook_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.webhook_api.id
  resource_id             = aws_api_gateway_rest_api.webhook_api.root_resource_id
  http_method             = aws_api_gateway_method.webhook_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_integration.invoke_arn
  credentials             = aws_iam_role.spacelift_role.arn
}

resource "aws_api_gateway_stage" "webhook_stage" {
  deployment_id = aws_api_gateway_deployment.webhook_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  stage_name    = "webhook"
}

resource "aws_api_gateway_deployment" "webhook_deployment" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.webhook_post,
      aws_api_gateway_integration.lambda_integration,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
