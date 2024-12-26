# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- networking_account/main.tf ---

# ---------- AWS CLOUD WAN ----------
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

  network_function_groups {
    name                          = "inspectionVpcs"
    require_attachment_acceptance = false
  }

  dynamic "segment_actions" {
    for_each = var.routing_domains
    iterator = routing_domain

    content {
      action  = "send-to"
      segment = routing_domain.value
      via {
        network_function_groups = ["inspectionVpcs"]
      }
    }
  }

  segment_actions {
    action  = "send-via"
    segment = "prod"
    mode    = "single-hop"

    when_sent_to {
      segments = ["nonprod"]
    }

    via {
      network_function_groups = ["inspectionVpcs"]

      with_edge_override {
        edge_sets         = [["us-west-2", "eu-west-1"], ["us-west-2", "ap-southeast-2"]]
        use_edge_location = "us-west-2"
      }
      with_edge_override {
        edge_sets         = [["eu-west-1", "ap-southeast-2"]]
        use_edge_location = "eu-west-1"
      }
    }
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "inspection"
      value    = "true"
    }
    action {
      add_to_network_function_group = "inspectionVpcs"
    }
  }

  attachment_policies {
    rule_number     = 200
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

locals {
  core_network = {
    id  = aws_networkmanager_core_network.core_network.id
    arn = aws_networkmanager_core_network.core_network.arn
  }
}

resource "aws_ssm_parameter" "core_network" {
  provider = aws.awsoregon

  name  = "core_network"
  type  = "String"
  value = jsonencode(local.core_network)
}

# Inspection VPC (attached to Core Network) + AWS Network Firewall
module "oregon_inspection" {
  source    = "aws-ia/cloudwan/aws"
  version   = "3.2.0"
  providers = { aws = aws.awsoregon }

  core_network_arn = aws_networkmanager_core_network.core_network.arn

  ipv4_network_definition = "10.0.0.0/16"
  central_vpcs = {
    inspection = {
      type       = "egress_with_inspection"
      name       = "inspection-vpc-cwan"
      cidr_block = var.inspection_vpc.cidr_block
      az_count   = var.inspection_vpc.number_azs

      subnets = {
        public    = { netmask = var.inspection_vpc.public_subnet_netmask }
        endpoints = { netmask = var.inspection_vpc.endpoints_subnet_netmask }
        core_network = {
          netmask = var.inspection_vpc.cwan_subnet_netmask

          tags = { inspection = "true" }
        }
      }
    }
  }

  aws_network_firewall = {
    inspection = {
      name        = "anfw-cwan-oregon"
      description = "AWS Network Firewall - us-west-2"
      policy_arn  = aws_networkfirewall_firewall_policy.oregon_anfw_policy.arn
    }
  }
}

module "ireland_inspection" {
  source    = "aws-ia/cloudwan/aws"
  version   = "3.2.0"
  providers = { aws = aws.awsireland }

  core_network_arn = aws_networkmanager_core_network.core_network.arn

  ipv4_network_definition = "10.1.0.0/16"
  central_vpcs = {
    inspection = {
      type       = "egress_with_inspection"
      name       = "inspection-vpc-cwan"
      cidr_block = var.inspection_vpc.cidr_block
      az_count   = var.inspection_vpc.number_azs

      subnets = {
        public    = { netmask = var.inspection_vpc.public_subnet_netmask }
        endpoints = { netmask = var.inspection_vpc.endpoints_subnet_netmask }
        core_network = {
          netmask = var.inspection_vpc.cwan_subnet_netmask

          tags = { inspection = "true" }
        }
      }
    }
  }

  aws_network_firewall = {
    inspection = {
      name        = "anfw-cwan-ireland"
      description = "AWS Network Firewall - eu-west-1"
      policy_arn  = aws_networkfirewall_firewall_policy.ireland_anfw_policy.arn
    }
  }
}

module "sydney_inspection" {
  source    = "aws-ia/cloudwan/aws"
  version   = "3.2.0"
  providers = { aws = aws.awssydney }

  core_network_arn = aws_networkmanager_core_network.core_network.arn

  ipv4_network_definition = "10.2.0.0/16"
  central_vpcs = {
    inspection = {
      type       = "egress_with_inspection"
      name       = "inspection-vpc-cwan"
      cidr_block = var.inspection_vpc.cidr_block
      az_count   = var.inspection_vpc.number_azs

      subnets = {
        public    = { netmask = var.inspection_vpc.public_subnet_netmask }
        endpoints = { netmask = var.inspection_vpc.endpoints_subnet_netmask }
        core_network = {
          netmask = var.inspection_vpc.cwan_subnet_netmask

          tags = { inspection = "true" }
        }
      }
    }
  }

  aws_network_firewall = {
    inspection = {
      name        = "anfw-cwan-sydney"
      description = "AWS Network Firewall - ap-southeast-2"
      policy_arn  = aws_networkfirewall_firewall_policy.sydney_anfw_policy.arn
    }
  }
}