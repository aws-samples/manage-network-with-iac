# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modulest/prefix_lists/main.tf ---

# ---------- AWS REGIONS ----------
data "aws_region" "oregon" {
  provider = aws.awsoregon
}

data "aws_region" "tokyo" {
  provider = aws.awstokyo
}

# ---------- IPv4 PRODUCTION PREFIX LIST ----------
# Tokyo CIDRs in Oregon Prefix List
resource "aws_ec2_managed_prefix_list" "tokyo_prod_ipv4" {
  provider = aws.awsoregon

  name           = "IPv4 prod - ${data.aws_region.tokyo.name}"
  address_family = "IPv4"
  max_entries    = length({ for k, v in var.tokyo_vpcs : k => v if v.routing_domain == "prod" })

  tags = {
    Name = "pl-${data.aws_region.tokyo.name}-prod-ipv4"
  }
}

resource "aws_ec2_managed_prefix_list_entry" "tokyo_prod_ipv4_entry" {
  for_each = { for k, v in var.tokyo_vpcs : k => v if v.routing_domain == "prod" }
  provider = aws.awsoregon

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.tokyo_prod_ipv4.id
}

# Oregon CIDRs in Tokyo Prefix List
resource "aws_ec2_managed_prefix_list" "oregon_prod_ipv4" {
  provider = aws.awstokyo

  name           = "IPv4 prod - ${data.aws_region.oregon.name}"
  address_family = "IPv4"
  max_entries    = length({ for k, v in var.oregon_vpcs : k => v if v.routing_domain == "prod" })

  tags = {
    Name = "pl-${data.aws_region.oregon.name}-prod-ipv4"
  }
}

resource "aws_ec2_managed_prefix_list_entry" "oregon_prod_ipv4_entry" {
  for_each = { for k, v in var.oregon_vpcs : k => v if v.routing_domain == "prod" }
  provider = aws.awstokyo

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.oregon_prod_ipv4.id
}

# ---------- IPv4 NON-PRODUCTION PREFIX LIST ----------
# Tokyo CIDRs in Oregon Prefix List
resource "aws_ec2_managed_prefix_list" "tokyo_nonprod_ipv4" {
  provider = aws.awsoregon

  name           = "IPv4 nonprod - ${data.aws_region.tokyo.name}"
  address_family = "IPv4"
  max_entries    = length({ for k, v in var.tokyo_vpcs : k => v if v.routing_domain == "nonprod" })

  tags = {
    Name = "pl-${data.aws_region.tokyo.name}-nonprod-ipv4"
  }
}

resource "aws_ec2_managed_prefix_list_entry" "tokyo_nonprod_ipv4_entry" {
  for_each = { for k, v in var.tokyo_vpcs : k => v if v.routing_domain == "nonprod" }
  provider = aws.awsoregon

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.tokyo_nonprod_ipv4.id
}

# Oregon CIDRs in Tokyo Prefix List
resource "aws_ec2_managed_prefix_list" "oregon_nonprod_ipv4" {
  provider = aws.awstokyo

  name           = "IPv4 nonprod - ${data.aws_region.oregon.name}"
  address_family = "IPv4"
  max_entries    = length({ for k, v in var.oregon_vpcs : k => v if v.routing_domain == "nonprod" })

  tags = {
    Name = "pl-${data.aws_region.oregon.name}-nonprod-ipv4"
  }
}

resource "aws_ec2_managed_prefix_list_entry" "oregon_nonprod_ipv4_entry" {
  for_each = { for k, v in var.oregon_vpcs : k => v if v.routing_domain == "nonprod" }
  provider = aws.awstokyo

  cidr           = each.value.cidr_block
  description    = each.key
  prefix_list_id = aws_ec2_managed_prefix_list.oregon_nonprod_ipv4.id
}