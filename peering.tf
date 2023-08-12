# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/peering.tf ---

# ---------- TRANSIT GATEWAY PEERING ----------
# Peering request (us-west-2)
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  provider = aws.awsoregon

  peer_region             = var.aws_regions.stockholm
  peer_transit_gateway_id = module.stockholm_hubspoke.transit_gateway.id
  transit_gateway_id      = module.oregon_hubspoke.transit_gateway.id

  tags = {
    Name = "tgw-peering-${var.aws_regions.stockholm}"
  }
}

# Peering accepter (eu-north-1)
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
  provider = aws.awsstockholm

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

# ---------- TRANSIT GATEWAY RESOURCES (eu-north-1) ----------
# Route table & association
resource "aws_ec2_transit_gateway_route_table" "stockholm_tgw_rt_peering" {
  provider = aws.awsstockholm

  transit_gateway_id = module.stockholm_hubspoke.transit_gateway.id

  tags = {
    Name = "peering-rt"
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

resource "aws_ec2_transit_gateway_route_table_association" "stockholm_tgw_rt_peering_assoc" {
  provider = aws.awsstockholm

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.stockholm_tgw_rt_peering.id
}

# Propagation - Spoke VPCs to peering route table
resource "aws_ec2_transit_gateway_route_table_propagation" "stockholm_tgw_rt_peering_prop" {
  provider = aws.awsstockholm
  for_each = module.stockholm_vpcs

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.stockholm_tgw_rt_peering.id
}

# ---------- PREFIX LISTS ----------
# Managed Prefix Lists - to use in the Transit Gateway routes
module "prefix_lists" {
  source = "./modules/prefix_lists"
  providers = {
    aws.awsoregon    = aws.awsoregon
    aws.awsstockholm = aws.awsstockholm
  }

  oregon_vpcs    = var.vpcs.oregon
  stockholm_vpcs = var.vpcs.stockholm
}

# ---------- TRANSIT GATEWAY STATIC ROUTES (us-west-2) ----------
# Static route - Oregon Prod to Stockholm Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_to_stockholm_prod" {
  provider = aws.awsoregon

  prefix_list_id                 = module.prefix_lists.stockholm_prefix_lists.prod
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Static route - Oregon Non-Prod to Stockholm Non-Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_to_stockholm_nonprod" {
  provider = aws.awsoregon

  prefix_list_id                 = module.prefix_lists.stockholm_prefix_lists.nonprod
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Blackhole route - Oregon Prod to Stockholm Non-prod
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_prod_to_stockholm_nonprod_blackhole" {
  provider = aws.awsoregon

  blackhole                      = true
  prefix_list_id                 = module.prefix_lists.stockholm_prefix_lists.nonprod
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id
}

# Blackhole route - Oregon Non-prod to Stockholm prod
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_nonprod_to_stockholm_prod_blackhole" {
  provider = aws.awsoregon

  blackhole                      = true
  prefix_list_id                 = module.prefix_lists.stockholm_prefix_lists.prod
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id
}

# ---------- TRANSIT GATEWAY STATIC ROUTES (eu-north-1) ----------
# Static route - Stockholm Prod to Oregon Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "stockholm_to_oregon_prod" {
  provider = aws.awsstockholm

  prefix_list_id                 = module.prefix_lists.oregon_prefix_lists.prod
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.stockholm_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Static route - Stockholm Non-Prod to Oregon Non-Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "stockholm_to_oregon_nonprod" {
  provider = aws.awsstockholm

  prefix_list_id                 = module.prefix_lists.oregon_prefix_lists.nonprod
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.stockholm_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Blackhole route - Stockholm Prod to Oregon Non-prod
resource "aws_ec2_transit_gateway_prefix_list_reference" "stockholm_prod_to_oregon_nonprod_blackhole" {
  provider = aws.awsstockholm

  blackhole                      = true
  prefix_list_id                 = module.prefix_lists.oregon_prefix_lists.nonprod
  transit_gateway_route_table_id = module.stockholm_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id
}

# Blackhole route - Stockholm Non-prod to Oregon prod
resource "aws_ec2_transit_gateway_prefix_list_reference" "stockholm_nonprod_to_oregon_prod_blackhole" {
  provider = aws.awsstockholm

  blackhole                      = true
  prefix_list_id                 = module.prefix_lists.oregon_prefix_lists.prod
  transit_gateway_route_table_id = module.stockholm_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id
}