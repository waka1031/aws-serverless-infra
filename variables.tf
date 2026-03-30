variable "project" {
  description = "Project identifier used for resource naming and tagging"
  type        = string
  default     = "nba-moments"
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

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
}

variable "lambda_log_retention_in_days" {
  description = "Lambda CloudWatch Logs retention period in days"
  type        = number
}
