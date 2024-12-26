# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- networking_account/firewall_policy.tf ---

# ---------- FIREWALL POLICY OREGON (us-west-2) ----------
# Firewall policy
resource "aws_networkfirewall_firewall_policy" "oregon_anfw_policy" {
  provider = aws.awsoregon

  name = "firewall-policy-${var.identifier}"

  firewall_policy {

    # Stateless configuration
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.oregon_drop_remote.arn
    }

    # Stateful configuration
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    stateful_default_actions = ["aws:drop_strict", "aws:alert_strict"]
    stateful_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.oregon_allow_domains.arn
    }
    stateful_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.oregon_allow_routingdomains.arn
    }
  }
}

# Stateless Rule Group - Dropping any SSH connection
resource "aws_networkfirewall_rule_group" "oregon_drop_remote" {
  provider = aws.awsoregon

  capacity = 2
  name     = "drop-remote-${var.identifier}"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {

        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [6]
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 0
                to_port   = 65535
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 22
                to_port   = 22
              }
            }
          }
        }
      }
    }
  }
}

# Stateful Rule Group - Allowing access to .amazon.com (HTTPS)
resource "aws_networkfirewall_rule_group" "oregon_allow_domains" {
  provider = aws.awsoregon

  capacity = 10
  name     = "allow-domains-${var.identifier}"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = <<EOF
      pass tcp any any <> $EXTERNAL_NET 443 (msg:"Allowing TCP in port 443"; flow:not_established; sid:1; rev:1;)
      pass tls any any -> $EXTERNAL_NET 443 (tls.sni; dotprefix; content:".amazon.com"; endswith; msg:"Allowing .amazon.com HTTPS requests"; sid:2; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

# Stateful Rule Group - Allowing access between routing domains
resource "aws_networkfirewall_rule_group" "oregon_allow_routingdomains" {
  provider = aws.awsoregon

  capacity = 10
  name     = "allow-routingdomains-${var.identifier}"
  type     = "STATEFUL"

  rule_group {
    rule_variables {
      ip_sets {
        key = "PROD"
        ip_set {
          definition = ["10.0.0.0/24", "10.1.0.0/24"]
        }
      }
      ip_sets {
        key = "NONPROD"
        ip_set {
          definition = ["10.0.1.0/24", "10.1.1.0/24"]
        }
      }
    }

    rules_source {
      rules_string = <<EOF
      pass icmp $PROD any -> $PROD any (msg:"Allowing any traffic between PROD VPCs"; flow:not_established; sid:3; rev:1;)
      pass icmp $NONPROD any -> $NONPROD any (msg:"Allowing any traffic between NONPROD VPCs"; flow:not_established; sid:4; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

# ---------- FIREWALL POLICY IRELAND (eu-west-1) ----------
# Firewall policy
resource "aws_networkfirewall_firewall_policy" "ireland_anfw_policy" {
  provider = aws.awsireland

  name = "firewall-policy-${var.identifier}"

  firewall_policy {

    # Stateless configuration
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.ireland_drop_remote.arn
    }

    # Stateful configuration
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    stateful_default_actions = ["aws:drop_strict", "aws:alert_strict"]
    stateful_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.ireland_allow_domains.arn
    }
    stateful_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.ireland_allow_routingdomains.arn
    }
  }
}

# Stateless Rule Group - Dropping any SSH connection
resource "aws_networkfirewall_rule_group" "ireland_drop_remote" {
  provider = aws.awsireland

  capacity = 2
  name     = "drop-remote-${var.identifier}"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {

        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [6]
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 0
                to_port   = 65535
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 22
                to_port   = 22
              }
            }
          }
        }
      }
    }
  }
}

# Stateful Rule Group - Allowing access to .amazon.com (HTTPS)
resource "aws_networkfirewall_rule_group" "ireland_allow_domains" {
  provider = aws.awsireland

  capacity = 10
  name     = "allow-domains-${var.identifier}"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = <<EOF
      pass tcp any any <> $EXTERNAL_NET 443 (msg:"Allowing TCP in port 443"; flow:not_established; sid:1; rev:1;)
      pass tls any any -> $EXTERNAL_NET 443 (tls.sni; dotprefix; content:".amazon.com"; endswith; msg:"Allowing .amazon.com HTTPS requests"; sid:2; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

# Stateful Rule Group - Allowing access between routing domains
resource "aws_networkfirewall_rule_group" "ireland_allow_routingdomains" {
  provider = aws.awsireland

  capacity = 10
  name     = "allow-routingdomains-${var.identifier}"
  type     = "STATEFUL"

  rule_group {
    rule_variables {
      ip_sets {
        key = "PROD"
        ip_set {
          definition = ["10.0.0.0/24", "10.1.0.0/24"]
        }
      }
      ip_sets {
        key = "NONPROD"
        ip_set {
          definition = ["10.0.1.0/24", "10.1.1.0/24"]
        }
      }
    }

    rules_source {
      rules_string = <<EOF
      pass icmp $PROD any -> $PROD any (msg:"Allowing any traffic between PROD VPCs"; flow:not_established; sid:3; rev:1;)
      pass icmp $NONPROD any -> $NONPROD any (msg:"Allowing any traffic between NONPROD VPCs"; flow:not_established; sid:4; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}

# ---------- FIREWALL POLICY SYDNEY (ap-southeast-2) ----------
# Firewall policy
resource "aws_networkfirewall_firewall_policy" "sydney_anfw_policy" {
  provider = aws.awssydney

  name = "firewall-policy-${var.identifier}"

  firewall_policy {

    # Stateless configuration
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.sydney_drop_remote.arn
    }

    # Stateful configuration
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    stateful_default_actions = ["aws:drop_strict", "aws:alert_strict"]
    stateful_rule_group_reference {
      priority     = 10
      resource_arn = aws_networkfirewall_rule_group.sydney_allow_domains.arn
    }
  }
}

# Stateless Rule Group - Dropping any SSH connection
resource "aws_networkfirewall_rule_group" "sydney_drop_remote" {
  provider = aws.awssydney

  capacity = 2
  name     = "drop-remote-${var.identifier}"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {

        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [6]
              source {
                address_definition = "0.0.0.0/0"
              }
              source_port {
                from_port = 0
                to_port   = 65535
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
              destination_port {
                from_port = 22
                to_port   = 22
              }
            }
          }
        }
      }
    }
  }
}

# Stateful Rule Group - Allowing access to .amazon.com (HTTPS)
resource "aws_networkfirewall_rule_group" "sydney_allow_domains" {
  provider = aws.awssydney

  capacity = 10
  name     = "allow-domains-${var.identifier}"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = <<EOF
      pass tcp any any <> $EXTERNAL_NET 443 (msg:"Allowing TCP in port 443"; flow:not_established; sid:1; rev:1;)
      pass tls any any -> $EXTERNAL_NET 443 (tls.sni; dotprefix; content:".amazon.com"; endswith; msg:"Allowing .amazon.com HTTPS requests"; sid:2; rev:1;)
      EOF
    }
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }
}