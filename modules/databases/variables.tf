# Input variables consumed by the databases module.

variable "name_prefix" {
  description = "Name prefix for database resources."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for database subnet group."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for DB security group."
  type        = string
}

variable "db_engine" {
  description = "Database engine."
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Database allocated storage (GB)."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database master username."
  type        = string
}

variable "db_password" {
  description = "Database master password."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
