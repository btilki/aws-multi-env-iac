# Outputs from bootstrap resources for visibility and integration.

output "state_bucket_name" {
  description = "S3 bucket used for remote state."
  value       = aws_s3_bucket.tfstate.id
}

output "lock_table_name" {
  description = "DynamoDB lock table used for Terraform state locking."
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "state_prefixes" {
  description = "Standardized state prefixes by environment."
  value       = [for env in var.environment_names : "${env}/terraform.tfstate"]
}
