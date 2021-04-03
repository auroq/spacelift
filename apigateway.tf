resource "aws_api_gateway_account" "api_gateway_cloudwatch" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_api_gateway_rest_api" "spacelift_webhook" {
  name        = var.api_name
  description = "API Gateway for accepting webhooks from Spacelift"
}

resource "aws_api_gateway_method" "spacelift_webhook" {
  rest_api_id   = aws_api_gateway_rest_api.spacelift_webhook.id
  resource_id   = aws_api_gateway_rest_api.spacelift_webhook.root_resource_id
  http_method   = "POST"
  authorization = "NONE"

  request_models = {
    "application/json" = aws_api_gateway_model.webhook_body.name
  }
}

resource "aws_api_gateway_method_settings" "spacelift_webhook" {
  rest_api_id = aws_api_gateway_rest_api.spacelift_webhook.id
  stage_name  = aws_api_gateway_stage.spacelift_webhook.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
}
//
//resource "aws_api_gateway_method_response" "response_200" {
//  rest_api_id = aws_api_gateway_rest_api.spacelift_webhook.id
//  resource_id = aws_api_gateway_rest_api.spacelift_webhook.root_resource_id
//  http_method = aws_api_gateway_method.spacelift_webhook.http_method
//  status_code = "200"
//}
//
//resource "aws_api_gateway_integration_response" "spacelift_webhook_response" {
//  depends_on = [
//  aws_api_gateway_integration.spacelift_webhook]
//  rest_api_id = aws_api_gateway_rest_api.spacelift_webhook.id
//  resource_id = aws_api_gateway_rest_api.spacelift_webhook.root_resource_id
//  http_method = aws_api_gateway_method.spacelift_webhook.http_method
//  status_code = aws_api_gateway_method_response.response_200.status_code
//}

resource "aws_api_gateway_stage" "spacelift_webhook" {
  deployment_id = aws_api_gateway_deployment.spacelift_webhook.id
  rest_api_id   = aws_api_gateway_rest_api.spacelift_webhook.id
  stage_name    = "webhook"
}

resource "aws_api_gateway_deployment" "spacelift_webhook" {
  rest_api_id = aws_api_gateway_rest_api.spacelift_webhook.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.spacelift_webhook,
      aws_api_gateway_integration.spacelift_webhook,
//      aws_api_gateway_integration_response.spacelift_webhook_response,
//      aws_api_gateway_authorizer.spacelift_webhook_verification,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_integration" "spacelift_webhook" {
  rest_api_id             = aws_api_gateway_rest_api.spacelift_webhook.id
  resource_id             = aws_api_gateway_rest_api.spacelift_webhook.root_resource_id
  http_method             = aws_api_gateway_method.spacelift_webhook.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.spacelift_webhook_verification.invoke_arn
  credentials             = aws_iam_role.spacelift_webhook.arn
}


resource "aws_api_gateway_model" "webhook_body" {
  rest_api_id  = aws_api_gateway_rest_api.spacelift_webhook.id
  name         = "webhookbody"
  description  = "Spacelift request model"
  content_type = "application/json"

  schema = <<EOF
{
    "type":"object",
    "properties":{
        "account":{ "type":"string" },
        "state":{ "type":"string" },
        "stateVersion":{ "type":"integer" },
        "timestamp":{ "type":"integer" },
        "run":{
            "type":"object",
            "properties":{
                "id":{ "type":"string" },
                "branch":{ "type":"string" },
                "commit":{
                    "type":"object",
                    "properties":{
                        "authorLogin":{ "type":"string" },
                        "authorName":{ "type":"string" },
                        "hash":{ "type":"string" },
                        "message":{ "type":"string" },
                        "timestamp":{ "type":"integer" },
                        "url":{ "type":"string" }
                    }
                },
                "createdAt":{ "type":"integer" },
                "delta":{
                    "type":"object",
                    "properties":{
                        "added":{ "type":"integer" },
                        "changed":{ "type":"integer" },
                        "deleted":{ "type":"integer" },
                        "resources":{ "type":"integer" }
                    }
                },
                "triggeredBy":{ "type":"string" },
                "type":{ "type":"string" }
            }
        },
        "stack":{
            "type":"object",
            "properties":{
                "id":{ "type":"string" },
                "name":{ "type":"string" },
                "description":{ "type":"string" },
                "labels":{
                    "type":"array",
                    "items":{ "type":"string" }
                }
            }
        }
    }
}
EOF
}
