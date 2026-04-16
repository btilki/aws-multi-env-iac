# Root-level AWS provider configuration.

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "Default AWS region."
  type        = string
  default     = "eu-west-1"
}
