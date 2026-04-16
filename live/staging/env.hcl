# Environment-specific values for the staging stack.

locals {
  environment = "staging"
  name_prefix = "multi-iac-staging"
  tags = {
    Environment = "staging"
    Project     = "multi-iac"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }

  vpc_cidr             = "10.20.0.0/16"
  availability_zones   = ["eu-central-1a", "eu-central-1b"]
  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
  instance_type        = "t3.small"
  ami_id               = ""
  db_username          = "appadmin"
}
