# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# ---------- OREGON (us-west-2) ENVIRONMENT ----------
# Amazon VPCs
module "oregon_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awsoregon }
  for_each  = var.vpcs.oregon

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    workload  = { cidrs = each.value.workload_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoints_subnet_cidrs }
  }
}

# EC2 instances
module "oregon_compute" {
  source    = "./modules/compute"
  providers = { aws = aws.awsoregon }
  for_each  = module.oregon_vpcs

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc                      = each.value
  vpc_information          = var.vpcs.oregon[each.key]
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
}

# ---------- STOCKHOLM (us-west-2) ENVIRONMENT ----------
# Amazon VPCs
module "stockholm_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awsstockholm }
  for_each  = var.vpcs.stockholm

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    workload  = { cidrs = each.value.workload_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoints_subnet_cidrs }
  }
}

# EC2 instances
module "stockholm_compute" {
  source    = "./modules/compute"
  providers = { aws = aws.awsstockholm }
  for_each  = module.stockholm_vpcs

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc                      = each.value
  vpc_information          = var.vpcs.stockholm[each.key]
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
}

# ---------- GLOBAL RESOURCES ----------
# IAM resources
module "iam" {
  source    = "./modules/iam"
  providers = { aws = aws.awsoregon }

  identifier = var.identifier
}