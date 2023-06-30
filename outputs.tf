# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/outputs.tf ---

output "vpcs" {
  description = "VPCs created."
  value = {
    oregon    = { for k, v in module.oregon_vpc : k => v.vpc_attributes.id }
    stockholm = { for k, v in module.stockholm_vpc : k => v.vpc_attributes.id }
  }
}

output "hub_and_spoke" {
  description = "Hub and Spoke information."
  value = {
    oregon = {
      transit_gateway              = module.oregon_hubspoke.transit_gateway.id
      transit_gateway_route_tables = { for k, v in module.oregon_hubspoke.transit_gateway_route_tables.spoke_vpcs : k => v.id }
    }
    stockholm = {
      transit_gateway              = module.stockholm_hubspoke.transit_gateway.id
      transit_gateway_route_tables = { for k, v in module.stockholm_hubspoke.transit_gateway_route_tables.spoke_vpcs : k => v.id }
    }
  }
}