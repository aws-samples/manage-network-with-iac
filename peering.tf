# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/peering.tf ---

# ---------- TRANSIT GATEWAY PEERING ----------
# Peering request (us-west-2)
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  provider = aws.awsoregon

  peer_region             = var.aws_regions.tokyo
  peer_transit_gateway_id = module.tokyo_hubspoke.transit_gateway.id
  transit_gateway_id      = module.oregon_hubspoke.transit_gateway.id

  tags = {
    Name = "tgw-peering-${var.aws_regions.tokyo}"
  }
}

# Peering accepter (ap-northeast-1)
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
  provider = aws.awstokyo

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id

  tags = {
    Name = "tgw-peering-${var.aws_regions.oregon}"
  }
}

# ---------- TRANSIT GATEWAY RESOURCES (us-west-2) ----------
# Route table & association
resource "aws_ec2_transit_gateway_route_table" "oregon_tgw_rt_peering" {
  provider = aws.awsoregon

  transit_gateway_id = module.oregon_hubspoke.transit_gateway.id

  tags = {
    Name = "peering-rt"
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

resource "aws_ec2_transit_gateway_route_table_association" "oregon_tgw_rt_peering_assoc" {
  provider = aws.awsoregon

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.oregon_tgw_rt_peering.id
}

# Propagation - Spoke VPCs to peering route table
resource "aws_ec2_transit_gateway_route_table_propagation" "oregon_tgw_rt_peering_prop" {
  provider = aws.awsoregon
  for_each = module.oregon_vpcs

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.oregon_tgw_rt_peering.id
}

# ---------- TRANSIT GATEWAY RESOURCES (ap-northeast-1) ----------
# Route table & association
resource "aws_ec2_transit_gateway_route_table" "tokyo_tgw_rt_peering" {
  provider = aws.awstokyo

  transit_gateway_id = module.tokyo_hubspoke.transit_gateway.id

  tags = {
    Name = "peering-rt"
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

resource "aws_ec2_transit_gateway_route_table_association" "tokyo_tgw_rt_peering_assoc" {
  provider = aws.awstokyo

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tokyo_tgw_rt_peering.id
}

# Propagation - Spoke VPCs to peering route table
resource "aws_ec2_transit_gateway_route_table_propagation" "tokyo_tgw_rt_peering_prop" {
  provider = aws.awstokyo
  for_each = module.tokyo_vpcs

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tokyo_tgw_rt_peering.id
}

# ---------- PREFIX LISTS ----------
# Managed Prefix Lists - to use in the Transit Gateway routes
module "prefix_lists" {
  source = "./modules/prefix_lists"
  providers = {
    aws.awsoregon = aws.awsoregon
    aws.awstokyo  = aws.awstokyo
  }

  oregon_vpcs = var.vpcs.oregon
  tokyo_vpcs  = var.vpcs.tokyo
}

# ---------- TRANSIT GATEWAY STATIC ROUTES (us-west-2) ----------
# Static route - Oregon Prod to Tokyo Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_to_tokyo_prod" {
  provider = aws.awsoregon

  prefix_list_id                 = module.prefix_lists.tokyo_prefix_lists.prod
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Static route - Oregon Non-Prod to Tokyo Non-Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_to_tokyo_nonprod" {
  provider = aws.awsoregon

  prefix_list_id                 = module.prefix_lists.tokyo_prefix_lists.nonprod
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Blackhole route - Oregon Prod to Tokyo Non-prod
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_prod_to_tokyo_nonprod_blackhole" {
  provider = aws.awsoregon

  blackhole                      = true
  prefix_list_id                 = module.prefix_lists.tokyo_prefix_lists.nonprod
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id
}

# Blackhole route - Oregon Non-prod to Tokyo prod
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_nonprod_to_tokyo_prod_blackhole" {
  provider = aws.awsoregon

  blackhole                      = true
  prefix_list_id                 = module.prefix_lists.tokyo_prefix_lists.prod
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id
}

# ---------- TRANSIT GATEWAY STATIC ROUTES (eu-north-1) ----------
# Static route - Tokyo Prod to Oregon Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "tokyo_to_oregon_prod" {
  provider = aws.awstokyo

  prefix_list_id                 = module.prefix_lists.oregon_prefix_lists.prod
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.tokyo_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Static route - Tokyo Non-Prod to Oregon Non-Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "tokyo_to_oregon_nonprod" {
  provider = aws.awstokyo

  prefix_list_id                 = module.prefix_lists.oregon_prefix_lists.nonprod
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.tokyo_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Blackhole route - Tokyo Prod to Oregon Non-prod
resource "aws_ec2_transit_gateway_prefix_list_reference" "tokyo_prod_to_oregon_nonprod_blackhole" {
  provider = aws.awstokyo

  blackhole                      = true
  prefix_list_id                 = module.prefix_lists.oregon_prefix_lists.nonprod
  transit_gateway_route_table_id = module.tokyo_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id
}

# Blackhole route - Tokyo Non-prod to Oregon prod
resource "aws_ec2_transit_gateway_prefix_list_reference" "tokyo_nonprod_to_oregon_prod_blackhole" {
  provider = aws.awstokyo

  blackhole                      = true
  prefix_list_id                 = module.prefix_lists.oregon_prefix_lists.prod
  transit_gateway_route_table_id = module.tokyo_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id
}