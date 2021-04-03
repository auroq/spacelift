data "archive_file" "lambda_source" {
  type        = "zip"
  output_path = "${path.module}/src.zip"
  source_file = "${path.module}/main.py"
}

resource "aws_lambda_function" "lambda_integration" {
  function_name    = var.webhook_name
  role             = aws_iam_role.spacelift_role.arn
  filename         = data.archive_file.lambda_source.output_path
  source_code_hash = data.archive_file.lambda_source.output_base64sha256
  handler          = "main.lambda_handler"
  memory_size      = 128
  runtime          = "python3.8"

  environment {
    variables = {
      SPACELIFT_WEBHOOK_SECRET = random_password.spacelift_webhook_secret.result
      DYNAMODB_TABLE_NAME      = aws_dynamodb_table.webhook_database.name
    }
  }

  tags = var.tags
}
