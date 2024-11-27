# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- spoke_account/main.tf ---

# ---------- OREGON (us-west-2) ENVIRONMENT ----------

# Amazon VPCs
module "oregon_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.4.3"
  providers = { aws = aws.awsoregon }
  for_each  = var.oregon_spoke_vpcs

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    workload  = { cidrs = each.value.private_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoint_subnet_cidrs }
  }
}

# EC2 instances & EC2 Instance Connect endpoint
module "oregon_compute" {
  source    = "../modules/compute"
  providers = { aws = aws.awsoregon }
  for_each  = module.oregon_vpcs

  identifier      = var.identifier
  vpc_name        = each.key
  vpc             = each.value
  vpc_information = var.oregon_spoke_vpcs[each.key]
}

# ---------- IRELAND (eu-west-1) ENVIRONMENT ----------

# Amazon VPCs
module "ireland_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.4.3"
  providers = { aws = aws.awsireland }
  for_each  = var.ireland_spoke_vpcs

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  subnets = {
    workload  = { cidrs = each.value.private_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoint_subnet_cidrs }
  }
}

# EC2 instances & EC2 Instance Connect endpoint
module "ireland_compute" {
  source    = "../modules/compute"
  providers = { aws = aws.awsireland }
  for_each  = module.ireland_vpcs

  identifier      = var.identifier
  vpc_name        = each.key
  vpc             = each.value
  vpc_information = var.ireland_spoke_vpcs[each.key]
}