# Environment-specific values for the dev stack.

locals {
  environment = "dev"
  name_prefix = "multi-iac-dev"
  tags = {
    Environment = "dev"
    Project     = "multi-iac"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }

  vpc_cidr             = "10.10.0.0/16"
  availability_zones   = ["eu-central-1a", "eu-central-1b"]
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
  instance_type        = "t3.micro"
  ami_id               = ""
  db_username          = "appadmin"
}
