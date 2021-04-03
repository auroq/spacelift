resource "spacelift_webhook" "api_gateway_integration" {
  endpoint = aws_api_gateway_stage.webhook_stage.invoke_url
  stack_id = var.spacelift_stack_id
  secret   = random_password.spacelift_webhook_secret.result
}
