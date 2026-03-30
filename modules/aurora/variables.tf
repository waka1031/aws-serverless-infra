variable "project" {
  description = "Project identifier used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where Aurora will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC (used for security group ingress)"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for the DB subnet group"
  type        = list(string)
}

variable "lambda_role_name" {
  description = "Name of the Lambda execution IAM role (used to attach RDS Data API policy)"
  type        = string
}

variable "database_name" {
  description = "Name of the default database to create"
  type        = string
  default     = "nba_moments"
}

variable "master_username" {
  description = "Master username for the Aurora cluster"
  type        = string
  default     = "nba_admin"
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "16.6"
}

variable "min_capacity" {
  description = "Minimum ACU capacity for Serverless v2 scaling"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "Maximum ACU capacity for Serverless v2 scaling"
  type        = number
  default     = 1.0
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the Aurora cluster"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final DB snapshot when the cluster is deleted"
  type        = bool
  default     = true
}
