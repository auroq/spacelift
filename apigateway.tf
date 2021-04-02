resource "aws_api_gateway_account" "api_gateway_cloudwatch" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_api_gateway_rest_api" "spacelift_webhook" {
  name        = var.api_name
  description = "API Gateway for accepting webhooks from Spacelift"
}

resource "aws_api_gateway_authorizer" "spacelift_webhook_verification" {
  name                             = "spacelift-webhook-verification"
  rest_api_id                      = aws_api_gateway_rest_api.spacelift_webhook.id
  authorizer_uri                   = aws_lambda_function.spacelift_webhook_verification.invoke_arn
  authorizer_credentials           = aws_iam_role.spacelift_webhook.arn
  type                             = "REQUEST"
  identity_source                  = "method.request.header.X-Signature-256"
  authorizer_result_ttl_in_seconds = 0
}

resource "aws_api_gateway_method" "spacelift_webhook" {
  rest_api_id   = aws_api_gateway_rest_api.spacelift_webhook.id
  resource_id   = aws_api_gateway_rest_api.spacelift_webhook.root_resource_id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.spacelift_webhook_verification.id

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

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.spacelift_webhook.id
  resource_id = aws_api_gateway_rest_api.spacelift_webhook.root_resource_id
  http_method = aws_api_gateway_method.spacelift_webhook.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "spacelift_webhook_response" {
  depends_on = [
  aws_api_gateway_integration.spacelift_webhook]
  rest_api_id = aws_api_gateway_rest_api.spacelift_webhook.id
  resource_id = aws_api_gateway_rest_api.spacelift_webhook.root_resource_id
  http_method = aws_api_gateway_method.spacelift_webhook.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

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
      aws_api_gateway_integration_response.spacelift_webhook_response,
      aws_api_gateway_authorizer.spacelift_webhook_verification,
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
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/PutItem"
  credentials             = aws_iam_role.spacelift_webhook.arn
  request_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
    "TableName": "${aws_dynamodb_table.spacelift_webhook.name}",
    "Item": { 
        "account": { "S": "$inputRoot.account" },
        "state": { "S": "$inputRoot.state" },
        "stateVersion": { "N": "$inputRoot.stateVersion" },
        "timestamp": { "N": "$inputRoot.timestamp" },
        "run": { "M": {
            "id": { "S": "$inputRoot.run.id" },
            "branch": { "S": "$inputRoot.run.branch" },
            "commit": { "M": {
                "authorLogin": { "S": "$inputRoot.run.commit.authorLogin" },
                "authorName": { "S": "$inputRoot.run.commit.authorName" },
                "hash": { "S": "$inputRoot.run.commit.hash" },
                "message": { "S": "$inputRoot.run.commit.message" },
                "timestamp": { "N": "$inputRoot.run.commit.timestamp" },
                "url": { "S": "$inputRoot.run.commit.url" }
            }},
            "createdAt": { "N": "$inputRoot.run.createdAt" },
            "delta": { "M": {
                "added": { "N": "$inputRoot.run.delta.added" },
                "changed": { "N": "$inputRoot.run.delta.changed" },
                "deleted": { "N": "$inputRoot.run.delta.deleted" },
                "resources": { "N": "$inputRoot.run.delta.resources" }
            }},
            "triggeredBy": { "S": "$inputRoot.run.triggeredBy" },
            "type": { "S": "$inputRoot.run.type" }
        }},
        "stack": { "M": {
            "id": { "S": "$inputRoot.stack.id" },
            "name": { "S": "$inputRoot.stack.name" },
            "description": { "S": "$inputRoot.stack.description" },
            "labels": { "L": [
                #foreach($elem in $inputRoot.stack.labels)
                { "S": "$elem" }#if($foreach.hasNext),#end
                #end
            ]}
        }}
    }
}
EOF
  }
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
