# Terragrunt unit for deploying networking resources in dev.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/networking"
}

inputs = {
  name_prefix          = local.env.locals.name_prefix
  vpc_cidr             = local.env.locals.vpc_cidr
  availability_zones   = local.env.locals.availability_zones
  public_subnet_cidrs  = local.env.locals.public_subnet_cidrs
  private_subnet_cidrs = local.env.locals.private_subnet_cidrs
  tags                 = local.env.locals.tags
}
