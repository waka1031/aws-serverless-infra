output "rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "execution_arn" {
  description = "Execution ARN of the REST API (used for Lambda permissions)"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "stage_invoke_url" {
  description = "Invoke URL of the API Gateway stage"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "api_key_value" {
  description = "Value of the API Key for CloudFront custom header"
  value       = aws_api_gateway_api_key.this.value
  sensitive   = true
}
