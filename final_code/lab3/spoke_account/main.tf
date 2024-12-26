# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- spoke_account/main.tf ---

# ---------- AWS CLOUD WAN ID & ARN ----------
data "aws_ssm_parameter" "core_network" {
  provider = aws.awsoregon

  name = "core_network"
}

locals {
  core_network = nonsensitive(jsondecode(data.aws_ssm_parameter.core_network.value))
}

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

  core_network = {
    id  = local.core_network.id
    arn = local.core_network.arn
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.private_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoint_subnet_cidrs }
    core_network = {
      cidrs = each.value.cwan_subnet_cidrs

      tags = {
        domain = each.value.type
      }
    }
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

  core_network = {
    id  = local.core_network.id
    arn = local.core_network.arn
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.private_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoint_subnet_cidrs }
    core_network = {
      cidrs = each.value.cwan_subnet_cidrs

      tags = {
        domain = each.value.type
      }
    }
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

# ---------- SYDNEY (ap-southeast-2) ENVIRONMENT ----------
# Amazon VPCs
module "sydney_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.4.3"
  providers = { aws = aws.awssydney }
  for_each  = var.sydney_spoke_vpcs

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  core_network = {
    id  = local.core_network.id
    arn = local.core_network.arn
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.private_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoint_subnet_cidrs }
    core_network = {
      cidrs = each.value.cwan_subnet_cidrs

      tags = {
        domain = each.value.type
      }
    }
  }
}

# EC2 instances & EC2 Instance Connect endpoint
module "sydney_compute" {
  source    = "../modules/compute"
  providers = { aws = aws.awssydney }
  for_each  = module.sydney_vpcs

  identifier      = var.identifier
  vpc_name        = each.key
  vpc             = each.value
  vpc_information = var.sydney_spoke_vpcs[each.key]
}