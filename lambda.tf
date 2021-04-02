data "archive_file" "lambda_src" {
  type        = "zip"
  output_path = "${path.module}/src.zip"
  source_file = "${path.module}/webhookverification.py"
}

resource "aws_lambda_function" "spacelift_webhook_verification" {
  function_name    = "spacelift-webhook-verification"
  role             = aws_iam_role.spacelift_webhook.arn
  filename         = data.archive_file.lambda_src.output_path
  source_code_hash = data.archive_file.lambda_src.output_base64sha256
  handler          = "webhookverification.lambda_handler"
  memory_size      = 128
  runtime          = "python3.8"

  environment {
    variables = {
      SPACELIFT_WEBHOOK_SECRET = random_password.spacelift_webhook_secret.result
    }
  }
}

resource "random_password" "spacelift_webhook_secret" {
  length  = 25
  special = true
}

resource "spacelift_webhook" "webhook" {
  endpoint = aws_api_gateway_stage.spacelift_webhook.invoke_url
  stack_id = var.spacelift_stack_id
  secret   = random_password.spacelift_webhook_secret.result
}
