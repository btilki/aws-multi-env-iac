# Input variables for bootstrap state resources.

variable "project_name" {
  description = "Project prefix for resource naming."
  type        = string
  default     = "multi-iac"
}

variable "aws_region" {
  description = "AWS region for state resources."
  type        = string
  default     = "eu-west-1"
}

variable "environment_names" {
  description = "Environment names used for state prefixes."
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}

variable "state_bucket_name" {
  description = "Global S3 bucket for Terraform state."
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform locks."
  type        = string
  default     = "tfstate-locks"
}
