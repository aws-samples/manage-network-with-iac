# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/cwan.tf ---

# ---------- AWS Cloud WAN ----------

# Global Network
resource "aws_networkmanager_global_network" "global_network" {
  provider    = aws.awsoregon
  description = "Global Network"

  tags = {
    Name = "global-network"
  }
}

# Core Network
resource "awscc_networkmanager_core_network" "core_network" {
  provider = awscc.awsccoregon

  description       = "Core Network"
  global_network_id = aws_networkmanager_global_network.global_network.id
  policy_document   = jsonencode(jsondecode(data.aws_networkmanager_core_network_policy_document.cwan_policy.json))
}

# Cloud WAN policy
data "aws_networkmanager_core_network_policy_document" "cwan_policy" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64512-64515"]
    edge_locations {
      location = "us-west-2"
    }
    edge_locations {
      location = "eu-north-1"
    }
  }

  segments {
    name                          = "prod"
    require_attachment_acceptance = false
    edge_locations                = ["us-west-2", "eu-north-1"]
  }
  segments {
    name                          = "nonprod"
    require_attachment_acceptance = false
    edge_locations                = ["us-west-2", "eu-north-1"]
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "env"
      value    = "prod"
    }
    action {
      association_method = "constant"
      segment            = "prod"
    }
  }
  attachment_policies {
    rule_number     = 200
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "env"
      value    = "nonprod"
    }
    action {
      association_method = "constant"
      segment            = "nonprod"
    }
  }
}