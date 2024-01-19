# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# ---------- OREGON (us-west-2) ENVIRONMENT ----------
# Amazon VPCs
module "oregon_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.4.1"
  providers = { aws = aws.awsoregon }

  name       = "vpc1"
  cidr_block = var.vpcs.oregon.vpc1.cidr_block
  az_count   = var.vpcs.oregon.vpc1.number_azs

  subnets = {
    workload  = { cidrs = var.vpcs.oregon.vpc1.workload_subnet_cidrs }
    endpoints = { cidrs = var.vpcs.oregon.vpc1.endpoints_subnet_cidrs }
  }
}

# EC2 instances & VPC endpoints
module "oregon_compute" {
  source    = "./modules/compute"
  providers = { aws = aws.awsoregon }

  identifier      = var.identifier
  vpc_name        = "vpc1"
  vpc             = module.oregon_vpcs
  vpc_information = var.vpcs.oregon.vpc1
}

# ---------- STOCKHOLM (us-west-2) ENVIRONMENT ----------



