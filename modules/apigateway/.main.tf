# api gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.project_name}"
}

# /items/ endpoint definition
resource "aws_api_gateway_resource" "items_resource" {
  path_part   = "items"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

# /items/{id} endpoint definition
resource "aws_api_gateway_resource" "items_id_resource" {
  path_part   = "{id}"
  parent_id   = aws_api_gateway_resource.items_resource.id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

# get /items/ method
resource "aws_api_gateway_method" "get_items_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# get /items/ integration with lambda
resource "aws_api_gateway_integration" "get_items_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.get_items_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.invoke_arn}"
}

# get /items/{id} method
resource "aws_api_gateway_method" "get_items_id_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items_id_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# get /items/{id} integration with lambda
resource "aws_api_gateway_integration" "get_items_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.items_id_resource.id
  http_method             = aws_api_gateway_method.get_items_id_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.invoke_arn}"
}

# put /items/ method
resource "aws_api_gateway_method" "put_items_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

# put /items/ integration with lambda
resource "aws_api_gateway_integration" "put_items_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.items_resource.id
  http_method             = aws_api_gateway_method.put_items_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.invoke_arn}"
}

# delete /items/{id} method
resource "aws_api_gateway_method" "delete_items_id_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items_id_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# delete /items/{id} integration with lambda
resource "aws_api_gateway_integration" "delete_items_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.items_id_resource.id
  http_method             = aws_api_gateway_method.delete_items_id_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.invoke_arn}"
}

# permission to enable api gateway to use the lambda function
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/"
}

# a snapshot of the api gateway configuration
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.get_items_method, aws_api_gateway_integration.get_items_integration]
}

# a name reference to a deployment
resource "aws_api_gateway_stage" "deployment" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}