# Input variables consumed by the networking module.

variable "name_prefix" {
  description = "Name prefix for networking resources."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "AZs for subnet placement."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
