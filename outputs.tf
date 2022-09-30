# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/outputs.tf ---

output "nvriginia" {
  description = "Resources deployed in North Virginia (us-east-1)."
  value = {
    transit_gateway_id  = module.hub_spoke_nvirginia.transit_gateway.id
    network_prefix_list = aws_ec2_managed_prefix_list.nvirginia_network.id
    spoke_vpcs          = { for k, v in module.nvirginia_spoke_vpcs : k => v.vpc_attributes.id }
    central_vpcs        = { for k, v in module.hub_spoke_nvirginia.central_vpcs : k => v.vpc_attributes.id }
    transit_gateway_route_tables = {
      spoke_vpcs   = { for k, v in module.hub_spoke_nvirginia.transit_gateway_route_tables.spoke_vpcs : k => v.id }
      central_vpcs = { for k, v in module.hub_spoke_nvirginia.transit_gateway_route_tables.central_vpcs : k => v.id }
    }
    network_firewall_id  = module.hub_spoke_nvirginia.aws_network_firewall.id
    ec2_instances        = { for k, v in module.nvirginia_compute : k => v.ec2_instances.*.id }
    vpc_endpoints        = module.nvirginia_vpc_endpoints.endpoint_ids
    private_hosted_zones = module.nvirginia_phz.private_hosted_zones
  }
}

output "ireland" {
  description = "Resources deployed in Ireland (eu-west-1)."
  value = {
    transit_gateway_id  = module.hub_spoke_ireland.transit_gateway.id
    network_prefix_list = aws_ec2_managed_prefix_list.ireland_network.id
    spoke_vpcs          = { for k, v in module.ireland_spoke_vpcs : k => v.vpc_attributes.id }
    central_vpcs        = { for k, v in module.hub_spoke_ireland.central_vpcs : k => v.vpc_attributes.id }
    transit_gateway_route_tables = {
      spoke_vpcs   = { for k, v in module.hub_spoke_ireland.transit_gateway_route_tables.spoke_vpcs : k => v.id }
      central_vpcs = { for k, v in module.hub_spoke_ireland.transit_gateway_route_tables.central_vpcs : k => v.id }
    }
    network_firewall_id  = module.hub_spoke_ireland.aws_network_firewall.id
    ec2_instances        = { for k, v in module.ireland_compute : k => v.ec2_instances.*.id }
    vpc_endpoints        = module.ireland_vpc_endpoints.endpoint_ids
    private_hosted_zones = module.ireland_phz.private_hosted_zones
  }
}