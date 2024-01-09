data "archive_file" "lambda" {
  type        = "zip"
  source_file = "modules/lambda/index.mjs"
  output_path = "modules/lambda/index.zip"
}

resource "aws_lambda_function" "crud-function" {
  filename      = "modules/lambda/index.zip"
  function_name = "${var.project_name}-function"
  role          = var.role_arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs18.x"
}

output "invoke_arn" {
  value = aws_lambda_function.crud-function.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.crud-function.function_name
}