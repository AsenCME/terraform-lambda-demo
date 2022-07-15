variable "stage" {
  type = string
  default = "dev"
}

resource "aws_apigatewayv2_api" "api" {
  name = "terraform-demo-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
    expose_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "api-stage" {
  api_id = aws_apigatewayv2_api.api.id
  name = var.stage
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api-log-group.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_integration" "terraform-api-handler" {
  api_id = aws_apigatewayv2_api.api.id
  integration_uri = aws_lambda_function.terraform-lambda-demo.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "terraform-api-route" {
  api_id = aws_apigatewayv2_api.api.id
  route_key = "GET /demo"
  target = "integrations/${aws_apigatewayv2_integration.terraform-api-handler.id}"
}

resource "aws_cloudwatch_log_group" "api-log-group" {
  name  = "/aws/terraform-demo-api/${aws_apigatewayv2_api.api.name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "api-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform-lambda-demo.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
