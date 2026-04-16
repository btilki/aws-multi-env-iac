# Shared Terragrunt root config for remote state and generated AWS provider settings.

locals {
  project_name = "multi-iac"
  aws_region   = "eu-central-1"
}

remote_state {
  backend = "s3"
  config = {
    # bucket       = "REPLACE_WITH_STATE_BUCKET"
    bucket         = "multiplatiacbucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "tfstate-locks"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}
