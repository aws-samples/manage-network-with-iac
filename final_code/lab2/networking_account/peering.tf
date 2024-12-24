# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- networking_account/peering.tf ---

# ---------- TRANSIT GATEWAY PEERING ----------
# Peering request (us-west-2)
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  provider = aws.awsoregon

  peer_region             = var.aws_regions.ireland
  peer_transit_gateway_id = module.ireland_hubspoke.transit_gateway.id
  transit_gateway_id      = module.oregon_hubspoke.transit_gateway.id

  tags = {
    Name = "tgw-peering-${var.aws_regions.ireland}"
  }
}

# Peering accepter (eu-west-1)
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
  provider = aws.awsireland

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

resource "aws_ec2_transit_gateway_route_table_propagation" "oregon_spoke_propagation_peering_rt" {
  for_each = local.oregon_spoke_vpcs
  provider = aws.awsoregon

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.oregon_tgw_rt_peering.id
}

# ---------- TRANSIT GATEWAY RESOURCES (eu-west-1) ----------
# Route table & association
resource "aws_ec2_transit_gateway_route_table" "ireland_tgw_rt_peering" {
  provider = aws.awsireland

  transit_gateway_id = module.ireland_hubspoke.transit_gateway.id

  tags = {
    Name = "peering-rt"
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

resource "aws_ec2_transit_gateway_route_table_association" "ireland_tgw_rt_peering_assoc" {
  provider = aws.awsireland

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ireland_tgw_rt_peering.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "ireland_spoke_propagation_peering_rt" {
  for_each = local.ireland_spoke_vpcs
  provider = aws.awsireland

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.ireland_tgw_rt_peering.id
}

# ---------- TRANSIT GATEWAY STATIC ROUTES (us-west-2) ----------
# Static route - Oregon Prod to Ireland Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_to_ireland_prod" {
  provider = aws.awsoregon

  prefix_list_id                 = aws_ec2_managed_prefix_list.ireland_prod.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Static route - Oregon Non-Prod to Ireland Non-Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "oregon_to_ireland_nonprod" {
  provider = aws.awsoregon

  prefix_list_id                 = aws_ec2_managed_prefix_list.ireland_nonprod.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# ---------- TRANSIT GATEWAY STATIC ROUTES (eu-west-1) ----------
# Static route - Ireland Prod to Oregon Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "ireland_to_oregon_prod" {
  provider = aws.awsireland

  prefix_list_id                 = aws_ec2_managed_prefix_list.oregon_prod.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.ireland_hubspoke.transit_gateway_route_tables.spoke_vpcs.prod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Static route - Ireland Non-Prod to Oregon Non-Prod (via peering)
resource "aws_ec2_transit_gateway_prefix_list_reference" "ireland_to_oregon_nonprod" {
  provider = aws.awsireland

  prefix_list_id                 = aws_ec2_managed_prefix_list.oregon_nonprod.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = module.ireland_hubspoke.transit_gateway_route_tables.spoke_vpcs.nonprod.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}