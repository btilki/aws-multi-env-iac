# Terragrunt unit for deploying database resources in staging.

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
  source = "../../../modules/databases"
}

inputs = {
  name_prefix          = local.env.locals.name_prefix
  vpc_id               = dependency.networking.outputs.vpc_id
  private_subnet_ids   = dependency.networking.outputs.private_subnet_ids
  db_name              = "appdb"
  db_username          = local.env.locals.db_username
  db_password          = get_env("TF_VAR_db_password")
  db_instance_class    = "db.t4g.small"
  db_allocated_storage = 40
  tags                 = local.env.locals.tags
}
