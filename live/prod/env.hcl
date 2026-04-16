# Environment-specific values for the prod stack.

locals {
  environment = "prod"
  name_prefix = "multi-iac-prod"
  tags = {
    Environment = "prod"
    Project     = "multi-iac"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }

  vpc_cidr             = "10.30.0.0/16"
  availability_zones   = ["eu-central-1a", "eu-central-1b"]
  public_subnet_cidrs  = ["10.30.1.0/24", "10.30.2.0/24"]
  private_subnet_cidrs = ["10.30.11.0/24", "10.30.12.0/24"]
  instance_type        = "t3.medium"
  ami_id               = ""
  db_username          = "appadmin"
}
