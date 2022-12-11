# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/outputs.tf ---

output "oregon" {
  description = "Resources deployed in Oregon (us-west-2)."
  value = {
    transit_gateway_id  = aws_ec2_transit_gateway.oregon_tgw.id
    network_prefix_list = aws_ec2_managed_prefix_list.oregon_network.id
    spoke_vpcs          = { for k, v in module.oregon_spoke_vpcs : k => v.vpc_attributes.id }
    central_vpcs        = { for k, v in module.hub_spoke_oregon.central_vpcs : k => v.vpc_attributes.id }
    transit_gateway_route_tables = {
      spoke_vpcs   = { for k, v in module.hub_spoke_oregon.transit_gateway_route_tables.spoke_vpcs : k => v.id }
      central_vpcs = { for k, v in module.hub_spoke_oregon.transit_gateway_route_tables.central_vpcs : k => v.id }
    }
    network_firewall_id  = module.hub_spoke_oregon.aws_network_firewall.id
    ec2_instances        = { for k, v in module.oregon_compute : k => v.ec2_instances.*.id }
    vpc_endpoints        = module.oregon_vpc_endpoints.endpoint_ids
    private_hosted_zones = module.oregon_phz.private_hosted_zones
  }
}

output "stockholm" {
  description = "Resources deployed in Stockholm (eu-north-1)."
  value = {
    transit_gateway_id  = aws_ec2_transit_gateway.stockholm_tgw.id
    network_prefix_list = aws_ec2_managed_prefix_list.stockholm_network.id
    spoke_vpcs          = { for k, v in module.stockholm_spoke_vpcs : k => v.vpc_attributes.id }
    central_vpcs        = { for k, v in module.hub_spoke_stockholm.central_vpcs : k => v.vpc_attributes.id }
    transit_gateway_route_tables = {
      spoke_vpcs   = { for k, v in module.hub_spoke_stockholm.transit_gateway_route_tables.spoke_vpcs : k => v.id }
      central_vpcs = { for k, v in module.hub_spoke_stockholm.transit_gateway_route_tables.central_vpcs : k => v.id }
    }
    network_firewall_id  = module.hub_spoke_stockholm.aws_network_firewall.id
    ec2_instances        = { for k, v in module.stockholm_compute : k => v.ec2_instances.*.id }
    vpc_endpoints        = module.stockholm_vpc_endpoints.endpoint_ids
    private_hosted_zones = module.stockholm_phz.private_hosted_zones
  }
}

output "cloud_wan" {
  description = "AWS Cloud WAN resources."
  value = {
    global_network_id = aws_networkmanager_global_network.global_network.id
    core_network_id   = awscc_networkmanager_core_network.core_network.core_network_id
    tgw_peerings = {
      oregon    = aws_networkmanager_transit_gateway_peering.cwan_oregon_peering.id
      stockholm = aws_networkmanager_transit_gateway_peering.cwan_stockholm_peering.id
    }
    route_table_attachments = {
      oregon    = { for k, v in aws_networkmanager_transit_gateway_route_table_attachment.oregon_cwan_tgw_rt_attachment : k => v.id }
      stockholm = { for k, v in aws_networkmanager_transit_gateway_route_table_attachment.stockholm_cwan_tgw_rt_attachment : k => v.id }
    }
  }
}