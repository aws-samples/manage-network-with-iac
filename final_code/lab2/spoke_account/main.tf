# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- spoke_account/main.tf ---

# ---------- OREGON (us-west-2) ENVIRONMENT ----------
data "aws_ssm_parameter" "oregon_tgw_id" {
  provider = aws.awsoregon

  name = "oregon_tgw_id"
}

# Amazon VPCs
module "oregon_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.4.3"
  providers = { aws = aws.awsoregon }
  for_each  = var.oregon_spoke_vpcs

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = data.aws_ssm_parameter.oregon_tgw_id.value
  transit_gateway_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.private_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoint_subnet_cidrs }
    transit_gateway = {
      cidrs                                           = each.value.tgw_subnet_cidrs
      transit_gateway_default_route_table_propagation = false
      transit_gateway_default_route_table_association = false
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
data "aws_ssm_parameter" "ireland_tgw_id" {
  provider = aws.awsireland

  name = "ireland_tgw_id"
}

# Amazon VPCs
module "ireland_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.4.3"
  providers = { aws = aws.awsireland }
  for_each  = var.ireland_spoke_vpcs

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = data.aws_ssm_parameter.ireland_tgw_id.value
  transit_gateway_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.private_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoint_subnet_cidrs }
    transit_gateway = {
      cidrs                                           = each.value.tgw_subnet_cidrs
      transit_gateway_default_route_table_propagation = false
      transit_gateway_default_route_table_association = false
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

# ---------- PARAMETERS (all AWS Regions) ----------
locals {
  oregon_spoke_vpcs = { for k, v in module.oregon_vpcs : k => {
    vpc_id                        = v.vpc_attributes.id
    transit_gateway_attachment_id = v.transit_gateway_attachment_id
    routing_domain                = var.oregon_spoke_vpcs[k].type
    cidr_block                    = var.oregon_spoke_vpcs[k].cidr_block
  } }

  ireland_spoke_vpcs = { for k, v in module.ireland_vpcs : k => {
    vpc_id                        = v.vpc_attributes.id
    transit_gateway_attachment_id = v.transit_gateway_attachment_id
    routing_domain                = var.ireland_spoke_vpcs[k].type
    cidr_block                    = var.ireland_spoke_vpcs[k].cidr_block
  } }
}

resource "aws_ssm_parameter" "oregon_spoke_vpcs" {
  provider = aws.awsoregon

  name  = "oregon_spoke_vpcs"
  type  = "String"
  value = jsonencode(local.oregon_spoke_vpcs)
}

resource "aws_ssm_parameter" "ireland_spoke_vpcs" {
  provider = aws.awsireland

  name  = "ireland_spoke_vpcs"
  type  = "String"
  value = jsonencode(local.ireland_spoke_vpcs)
}