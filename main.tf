terraform {
  required_version = "~> 1.14"
}

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
}

module "frontend" {
  source      = "./modules/frontend"
  project     = var.project
  environment = var.environment
  allowed_ips = var.allowed_ips

  api_gateway_invoke_url = module.api_gateway.stage_invoke_url
  api_key_value          = module.api_gateway.api_key_value
}

module "api_gateway" {
  source      = "./modules/api_gateway"
  project     = var.project
  environment = var.environment

  lambda_invoke_arn = module.lambda.invoke_arn
}

module "lambda" {
  source      = "./modules/lambda"
  project     = var.project
  environment = var.environment

  timeout               = var.lambda_timeout
  memory_size           = var.lambda_memory_size
  log_retention_in_days = var.lambda_log_retention_in_days

  api_gateway_execution_arn = module.api_gateway.execution_arn
}

module "aurora" {
  source      = "./modules/aurora"
  project     = var.project
  environment = var.environment

  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids
  lambda_role_name   = module.lambda.role_name
}
