variable "project" {
  description = "Project identifier used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway stage (e.g., https://xxx.execute-api.ap-northeast-1.amazonaws.com/dev)"
  type        = string
}

variable "api_key_value" {
  description = "API Key value to send as x-api-key header to API Gateway"
  type        = string
  sensitive   = true
}
