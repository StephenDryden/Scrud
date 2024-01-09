# api gateway
resource "aws_apigatewayv2_api" "main" {
  name = "${var.project_name}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.main_api_gw.arn

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
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "main_api_gw" {
  name = "/aws/api-gw/${aws_apigatewayv2_api.main.name}"

  retention_in_days = 30
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.main.id

  integration_type = "AWS_PROXY"
  integration_uri  = "${var.invoke_arn}"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_items" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /items"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "get_items_id" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /items/{id}"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "put_items" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "PUT /items"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_items_id" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "DELETE /items/{id}"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.function_name}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*/items"
}