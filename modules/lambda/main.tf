locals {
  name_prefix   = "${var.project}-${var.environment}"
  function_name = "${local.name_prefix}-lambda-moments"
}

# --- ダミーコードの zip 化（初回デプロイ用） ---

data "archive_file" "dummy" {
  type        = "zip"
  source_file = "${path.module}/src/index.mjs"
  output_path = "${path.module}/lambda.zip"
}

# --- Lambda 関数 ---

resource "aws_lambda_function" "this" {
  function_name    = local.function_name
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  timeout          = var.timeout
  memory_size      = var.memory_size
  filename         = data.archive_file.dummy.output_path
  source_code_hash = data.archive_file.dummy.output_base64sha256

  tags = {
    Name = local.function_name
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# --- IAM ロール ---

resource "aws_iam_role" "lambda" {
  name = "${local.name_prefix}-role-lambda-moments"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-role-lambda-moments"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- CloudWatch ロググループ ---

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.log_retention_in_days

  tags = {
    Name = "${local.function_name}-logs"
  }
}

# --- Lambda 呼び出し許可 ---

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
