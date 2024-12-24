# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- networking_account/main.tf ---

# ---------- OREGON (us-west-2) ENVIRONMENT ----------
data "aws_ssm_parameter" "oregon_spoke_vpcs" {
  provider = aws.awsoregon

  name = "oregon_spoke_vpcs"
}

locals {
  oregon_spoke_vpcs = nonsensitive(jsondecode(data.aws_ssm_parameter.oregon_spoke_vpcs.value))
}

# AWS Hub and Spoke environment
module "oregon_hubspoke" {
  source    = "aws-ia/network-hubandspoke/aws"
  version   = "3.2.0"
  providers = { aws = aws.awsoregon }

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-oregon"
    description     = "Transit Gateway - Oregon"
    amazon_side_asn = 65000
  }
  network_definition = {
    type  = "CIDR"
    value = "10.0.0.0/16"
  }

  central_vpcs = {
    inspection = {
      name       = "inspection-vpc"
      cidr_block = var.inspection_vpc.cidr_block
      az_count   = var.inspection_vpc.number_azs

      inspection_flow = "north-south"
      aws_network_firewall = {
        name        = "ANFW-${var.identifier}"
        description = "AWS Network Firewall - ${var.identifier}"
        policy_arn  = aws_networkfirewall_firewall_policy.oregon_anfw_policy.id
      }

      subnets = {
        public          = { netmask = var.inspection_vpc.public_subnet_netmask }
        endpoints       = { netmask = var.inspection_vpc.endpoints_subnet_netmask }
        transit_gateway = { netmask = var.inspection_vpc.tgw_subnet_netmask }
      }
    }
  }

  spoke_vpcs = {
    routing_domains = ["prod", "nonprod"]
    number_vpcs     = length(local.oregon_spoke_vpcs)
    vpc_information = { for k, v in local.oregon_spoke_vpcs : k => {
      vpc_id                        = v.vpc_id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      routing_domain                = v.routing_domain
    } }
  }
}

# ---------- IRELAND (eu-west-1) ENVIRONMENT ----------
data "aws_ssm_parameter" "ireland_spoke_vpcs" {
  provider = aws.awsireland

  name = "ireland_spoke_vpcs"
}

locals {
  ireland_spoke_vpcs = nonsensitive(jsondecode(data.aws_ssm_parameter.ireland_spoke_vpcs.value))
}

# AWS Hub and Spoke environment
module "ireland_hubspoke" {
  source    = "aws-ia/network-hubandspoke/aws"
  version   = "3.2.0"
  providers = { aws = aws.awsireland }

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-ireland"
    description     = "Transit Gateway - Ireland"
    amazon_side_asn = 65001
  }
  network_definition = {
    type  = "CIDR"
    value = "10.1.0.0/16"
  }

  central_vpcs = {
    inspection = {
      name       = "inspection-vpc"
      cidr_block = var.inspection_vpc.cidr_block
      az_count   = var.inspection_vpc.number_azs

      inspection_flow = "north-south"
      aws_network_firewall = {
        name        = "ANFW-${var.identifier}"
        description = "AWS Network Firewall - ${var.identifier}"
        policy_arn  = aws_networkfirewall_firewall_policy.ireland_anfw_policy.id
      }

      subnets = {
        public          = { netmask = var.inspection_vpc.public_subnet_netmask }
        endpoints       = { netmask = var.inspection_vpc.endpoints_subnet_netmask }
        transit_gateway = { netmask = var.inspection_vpc.tgw_subnet_netmask }
      }
    }
  }

  spoke_vpcs = {
    routing_domains = ["prod", "nonprod"]
    number_vpcs     = length(local.ireland_spoke_vpcs)
    vpc_information = { for k, v in local.ireland_spoke_vpcs : k => {
      vpc_id                        = v.vpc_id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      routing_domain                = v.routing_domain
    } }
  }
}

# ---------- PARAMETERS (all AWS Regions) ----------
resource "aws_ssm_parameter" "oregon_tgw_id" {
  provider = aws.awsoregon

  name  = "oregon_tgw_id"
  type  = "String"
  value = module.oregon_hubspoke.transit_gateway.id
}

resource "aws_ssm_parameter" "ireland_tgw_id" {
  provider = aws.awsireland

  name  = "ireland_tgw_id"
  type  = "String"
  value = module.ireland_hubspoke.transit_gateway.id
}

# ---------- PREFIX LISTS ----------
# Ireland Prod VPCs (Oregon)
resource "aws_ec2_managed_prefix_list" "ireland_prod" {
  provider = aws.awsoregon

  name           = "ireland_prod"
  address_family = "IPv4"
  max_entries    = 1
}

resource "aws_ec2_managed_prefix_list_entry" "ireland_prod_entries" {
  provider = aws.awsoregon
  for_each = {
    for k, v in local.ireland_spoke_vpcs : k => v
    if v.routing_domain == "prod"
  }

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.ireland_prod.id
}

# Ireland NonProd VPCs (Oregon)
resource "aws_ec2_managed_prefix_list" "ireland_nonprod" {
  provider = aws.awsoregon

  name           = "ireland_nonprod"
  address_family = "IPv4"
  max_entries    = 1
}

resource "aws_ec2_managed_prefix_list_entry" "ireland_nonprod_entries" {
  provider = aws.awsoregon
  for_each = {
    for k, v in local.ireland_spoke_vpcs : k => v
    if v.routing_domain == "nonprod"
  }

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.ireland_nonprod.id
}

# Oregon Prod VPCs (Ireland)
resource "aws_ec2_managed_prefix_list" "oregon_prod" {
  provider = aws.awsireland

  name           = "oregon_prod"
  address_family = "IPv4"
  max_entries    = 1
}

resource "aws_ec2_managed_prefix_list_entry" "oregon_prod_entries" {
  provider = aws.awsireland
  for_each = {
    for k, v in local.oregon_spoke_vpcs : k => v
    if v.routing_domain == "prod"
  }

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.oregon_prod.id
}

# Oregon NonProd VPCs (Ireland)
resource "aws_ec2_managed_prefix_list" "oregon_nonprod" {
  provider = aws.awsireland

  name           = "oregon_nonprod"
  address_family = "IPv4"
  max_entries    = 1
}

resource "aws_ec2_managed_prefix_list_entry" "oregon_nonprod_entries" {
  provider = aws.awsireland
  for_each = {
    for k, v in local.oregon_spoke_vpcs : k => v
    if v.routing_domain == "nonprod"
  }

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.oregon_nonprod.id
}