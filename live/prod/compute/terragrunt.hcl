# Terragrunt unit for deploying compute resources in prod.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

dependency "networking" {
  config_path                             = "../networking"
  skip_outputs                            = get_env("TG_SKIP_DEP_OUTPUTS", "false") == "true"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-00000000000000000", "subnet-11111111111111111"]
  }
}

terraform {
  source = "../../../modules/compute"
}

inputs = {
  name_prefix          = local.env.locals.name_prefix
  vpc_id               = dependency.networking.outputs.vpc_id
  private_subnet_ids   = dependency.networking.outputs.private_subnet_ids
  instance_type        = local.env.locals.instance_type
  ami_id               = local.env.locals.ami_id
  asg_min_size         = 2
  asg_max_size         = 6
  asg_desired_capacity = 3
  tags                 = local.env.locals.tags
}
