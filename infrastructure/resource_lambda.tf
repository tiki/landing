variable "aws_iam_role_lambda_exec" {}

data "aws_iam_role" "lambda_exec" {
  name = var.aws_iam_role_lambda_exec
}

resource "aws_lambda_function" "signup" {
  function_name = "Signup"

  s3_bucket = aws_s3_bucket.backend.bucket
  s3_key    = "${local.global_functions_version_pipe}/functions.zip"

  handler = "signup.handler"
  runtime = "nodejs12.x"

  tags = {
    Environment = var.global_tag_environment
    Service     = var.global_tag_service
  }

  environment {
    variables = {
      DYNAMODB_TABLE = var.global_dynamodb_table_name
    }
  }

  source_code_hash = filemd5(local.global_functions_zip_path)

  role = data.aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_permission" "api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.signup.execution_arn}/*/*"
}
