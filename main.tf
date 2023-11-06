# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# ---------- OREGON (us-west-2) ENVIRONMENT ----------
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
    number_vpcs     = length(var.vpcs.oregon)
    vpc_information = { for k, v in module.oregon_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      routing_domain                = var.vpcs.oregon[k].routing_domain
    } }
  }
}

# Amazon VPCs
module "oregon_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.4.1"
  providers = { aws = aws.awsoregon }
  for_each  = var.vpcs.oregon

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = module.oregon_hubspoke.transit_gateway.id
  transit_gateway_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.workload_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoints_subnet_cidrs }
    transit_gateway = {
      cidrs                                           = each.value.tgw_subnet_cidrs
      transit_gateway_default_route_table_propagation = false
      transit_gateway_default_route_table_association = false

      tags = { domain = each.value.routing_domain }
    }
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

# ---------- TOKYO (ap-northeast-1) ENVIRONMENT ----------
# AWS Hub and Spoke environment
module "tokyo_hubspoke" {
  source    = "aws-ia/network-hubandspoke/aws"
  version   = "3.2.0"
  providers = { aws = aws.awstokyo }

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-tokyo"
    description     = "Transit Gateway - Tokyo"
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
        policy_arn  = aws_networkfirewall_firewall_policy.tokyo_anfw_policy.id
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
    number_vpcs     = length(var.vpcs.tokyo)
    vpc_information = { for k, v in module.tokyo_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      routing_domain                = var.vpcs.tokyo[k].routing_domain
    } }
  }
}

# Amazon VPCs
module "tokyo_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.4.1"
  providers = { aws = aws.awstokyo }
  for_each  = var.vpcs.tokyo

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = module.tokyo_hubspoke.transit_gateway.id
  transit_gateway_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.workload_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoints_subnet_cidrs }
    transit_gateway = {
      cidrs                                           = each.value.tgw_subnet_cidrs
      transit_gateway_default_route_table_propagation = false
      transit_gateway_default_route_table_association = false

      tags = { domain = each.value.routing_domain }
    }
  }
}

# EC2 instances
module "tokyo_compute" {
  source    = "./modules/compute"
  providers = { aws = aws.awstokyo }
  for_each  = module.tokyo_vpcs

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc                      = each.value
  vpc_information          = var.vpcs.tokyo[each.key]
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
}

# ---------- GLOBAL RESOURCES ----------
# IAM resources
module "iam" {
  source    = "./modules/iam"
  providers = { aws = aws.awsoregon }

  identifier = var.identifier
}

# Global Network
resource "aws_networkmanager_global_network" "global_network" {
  provider = aws.awsoregon

  description = "Global Network - ${var.identifier}"

  tags = {
    Name = "global-network-${var.identifier}"
  }
}

# Core Network
resource "aws_networkmanager_core_network" "core_network" {
  provider = aws.awsoregon

  description       = "Core Network - ${var.identifier}"
  global_network_id = aws_networkmanager_global_network.global_network.id

  tags = {
    Name = "core-network-${var.identifier}"
  }
}

resource "aws_networkmanager_core_network_policy_attachment" "core_network_policy_attachment" {
  provider = aws.awsoregon

  core_network_id = aws_networkmanager_core_network.core_network.id
  policy_document = data.aws_networkmanager_core_network_policy_document.policy_document.json
}

# Core Network policy
data "aws_networkmanager_core_network_policy_document" "policy_document" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64520-65525"]

    dynamic "edge_locations" {
      for_each = values({ for k, v in var.aws_regions : k => v })
      iterator = region

      content {
        location = region.value
      }
    }
  }

  dynamic "segments" {
    for_each = var.routing_domains
    iterator = routing_domain

    content {
      name                          = routing_domain.value
      require_attachment_acceptance = false
      isolate_attachments           = routing_domain.value == "shared" ? true : false
    }
  }

  dynamic "segment_actions" {
    for_each = [for s in var.routing_domains : s if s != "shared"]
    iterator = routing_domain

    content {
      action     = "share"
      mode       = "attachment-route"
      segment    = routing_domain.value
      share_with = ["shared"]
    }
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type = "tag-exists"
      key  = "domain"
    }

    action {
      association_method = "tag"
      tag_value_of_key   = "domain"
    }
  }
}



