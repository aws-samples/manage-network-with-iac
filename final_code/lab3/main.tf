# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# AWS Cloud WAN Inspection VPC attachments
locals {
  inspection_cwan_attachments = [
    module.oregon_inspection.core_network_attachment.id,
    module.stockholm_inspection.core_network_attachment.id,
    module.sydney_inspection.core_network_attachment.id
  ]
}

# ---------- OREGON (us-west-2) ENVIRONMENT ----------
# Inspection VPC (attached to Core Network) + AWS Network Firewall
module "oregon_inspection" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awsoregon }

  name       = "inspection-${var.aws_regions.oregon}"
  cidr_block = var.inspection_vpc.cidr_block
  az_count   = var.inspection_vpc.number_azs

  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
  core_network_routes = {
    endpoints = "10.0.0.0/16"
  }

  subnets = {
    public = {
      netmask                   = var.inspection_vpc.public_subnet_netmask
      nat_gateway_configuration = "all_azs"
    }
    endpoints = {
      netmask                 = var.inspection_vpc.endpoints_subnet_netmask
      connect_to_public_natgw = true
    }
    core_network = {
      netmask = var.inspection_vpc.cwan_subnet_netmask

      tags = {
        domain = "shared"
      }
    }
  }
}

module "oregon_network_firewall" {
  source    = "aws-ia/networkfirewall/aws"
  version   = "1.0.0"
  providers = { aws = aws.awsoregon }

  network_firewall_name   = "anfw-${var.aws_regions.oregon}"
  network_firewall_description = "AWS Network Firewall - ${var.aws_regions.oregon}"
  network_firewall_policy = aws_networkfirewall_firewall_policy.oregon_anfw_policy.arn

  vpc_id      = module.oregon_inspection.vpc_attributes.id
  number_azs  = var.inspection_vpc.number_azs
  vpc_subnets = { for k, v in module.oregon_inspection.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" }

  routing_configuration = {
    centralized_inspection_with_egress = {
      connectivity_subnet_route_tables    = { for k, v in module.oregon_inspection.rt_attributes_by_type_by_az.core_network : k => v.id }
      public_subnet_route_tables          = { for k, v in module.oregon_inspection.rt_attributes_by_type_by_az.public : k => v.id }
      network_cidr_blocks                 = values({ for k, v in var.vpcs.oregon : k => v.cidr_block })
    }
  }
}

# Amazon VPCs
module "oregon_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awsoregon }
  for_each  = var.vpcs.oregon

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.workload_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoints_subnet_cidrs }
    core_network = {
      cidrs = each.value.cwan_subnet_cidrs

      tags = {
        domain = each.value.routing_domain
      }
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

# ---------- STOCKHOLM (us-west-2) ENVIRONMENT ----------
# Inspection VPC (attached to Core Network) + AWS Network Firewall
module "stockholm_inspection" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awsstockholm }

  name       = "inspection-${var.aws_regions.stockholm}"
  cidr_block = var.inspection_vpc.cidr_block
  az_count   = var.inspection_vpc.number_azs

  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
  core_network_routes = {
    endpoints = "10.1.0.0/16"
  }

  subnets = {
    public = {
      netmask                   = var.inspection_vpc.public_subnet_netmask
      nat_gateway_configuration = "all_azs"
    }
    endpoints = {
      netmask                 = var.inspection_vpc.endpoints_subnet_netmask
      connect_to_public_natgw = true
    }
    core_network = {
      netmask = var.inspection_vpc.cwan_subnet_netmask

      tags = {
        domain = "shared"
      }
    }
  }
}

module "stockholm_network_firewall" {
  source    = "aws-ia/networkfirewall/aws"
  version   = "1.0.0"
  providers = { aws = aws.awsstockholm }

  network_firewall_name        = "anfw-${var.aws_regions.stockholm}"
  network_firewall_description = "AWS Network Firewall - ${var.aws_regions.stockholm}"
  network_firewall_policy      = aws_networkfirewall_firewall_policy.stockholm_anfw_policy.arn

  vpc_id      = module.stockholm_inspection.vpc_attributes.id
  number_azs  = var.inspection_vpc.number_azs
  vpc_subnets = { for k, v in module.stockholm_inspection.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" }

  routing_configuration = {
    centralized_inspection_with_egress = {
      connectivity_subnet_route_tables = { for k, v in module.stockholm_inspection.rt_attributes_by_type_by_az.core_network : k => v.id }
      public_subnet_route_tables       = { for k, v in module.stockholm_inspection.rt_attributes_by_type_by_az.public : k => v.id }
      network_cidr_blocks              = values({ for k, v in var.vpcs.stockholm : k => v.cidr_block })
    }
  }
}

# Amazon VPCs
module "stockholm_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awsstockholm }
  for_each  = var.vpcs.stockholm

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.workload_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoints_subnet_cidrs }
    core_network = {
      cidrs = each.value.cwan_subnet_cidrs

      tags = {
        domain = each.value.routing_domain
      }
    }
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

# ---------- SYDNEY (ap-southeast-2) ENVIRONMENT ----------
# Inspection VPC (attached to Core Network) + AWS Network Firewall
module "sydney_inspection" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awssydney }

  name       = "inspection-${var.aws_regions.sydney}"
  cidr_block = var.inspection_vpc.cidr_block
  az_count   = var.inspection_vpc.number_azs

  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
  core_network_routes = {
    endpoints = "10.2.0.0/16"
  }

  subnets = {
    public = {
      netmask                   = var.inspection_vpc.public_subnet_netmask
      nat_gateway_configuration = "all_azs"
    }
    endpoints = {
      netmask                 = var.inspection_vpc.endpoints_subnet_netmask
      connect_to_public_natgw = true
    }
    core_network = {
      netmask = var.inspection_vpc.cwan_subnet_netmask

      tags = {
        domain = "shared"
      }
    }
  }
}

module "sydney_network_firewall" {
  source    = "aws-ia/networkfirewall/aws"
  version   = "1.0.0"
  providers = { aws = aws.awssydney }

  network_firewall_name        = "anfw-${var.aws_regions.sydney}"
  network_firewall_description = "AWS Network Firewall - ${var.aws_regions.sydney}"
  network_firewall_policy      = aws_networkfirewall_firewall_policy.sydney_anfw_policy.arn

  vpc_id      = module.sydney_inspection.vpc_attributes.id
  number_azs  = var.inspection_vpc.number_azs
  vpc_subnets = { for k, v in module.sydney_inspection.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" }

  routing_configuration = {
    centralized_inspection_with_egress = {
      connectivity_subnet_route_tables = { for k, v in module.sydney_inspection.rt_attributes_by_type_by_az.core_network : k => v.id }
      public_subnet_route_tables       = { for k, v in module.sydney_inspection.rt_attributes_by_type_by_az.public : k => v.id }
      network_cidr_blocks              = values({ for k, v in var.vpcs.sydney : k => v.cidr_block })
    }
  }
}

# Amazon VPCs
module "sydney_vpcs" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awssydney }
  for_each  = var.vpcs.sydney

  name       = each.key
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload  = { cidrs = each.value.workload_subnet_cidrs }
    endpoints = { cidrs = each.value.endpoints_subnet_cidrs }
    core_network = {
      cidrs = each.value.cwan_subnet_cidrs

      tags = {
        domain = each.value.routing_domain
      }
    }
  }
}

# EC2 instances
module "sydney_compute" {
  source    = "./modules/compute"
  providers = { aws = aws.awssydney }
  for_each  = module.sydney_vpcs

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc                      = each.value
  vpc_information          = var.vpcs.sydney[each.key]
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

  dynamic "segment_actions" {
    for_each = [for s in var.routing_domains : s if s != "shared"]
    iterator = routing_domain

    content {
      action                  = "create-route"
      segment                 = routing_domain.value
      destination_cidr_blocks = ["0.0.0.0/0"]
      destinations            = local.inspection_cwan_attachments
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