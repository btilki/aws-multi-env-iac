# Input variables consumed by the compute module.

variable "name_prefix" {
  description = "Name prefix for compute resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for target groups and ASG."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for launch template."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Optional AMI ID for EC2 launch template. If empty, resolve latest Amazon Linux 2023 AMI from SSM."
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "ASG minimum size."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "ASG maximum size."
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "ASG desired capacity."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
