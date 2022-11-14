# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# ---------- RESOURCES TO CREATE IN OREGON (us-west-2) ----------

# Hub and Spoke architecture
module "hub_spoke_oregon" {
  providers = {
    aws   = aws.awsoregon
    awscc = awscc.awsccoregon
  }

  source  = "aws-ia/network-hubandspoke/aws"
  version = "1.0.1"

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-us-west-2"
    description     = "AWS Transit Gateway - us-west-2"
    amazon_side_asn = var.transit_gateway_asn.oregon
  }

  network_definition = {
    type  = "PREFIX_LIST"
    value = aws_ec2_managed_prefix_list.oregon_network.id
  }

  central_vpcs = {
    inspection = {
      name            = "inspection-vpc-us-west-2"
      cidr_block      = "10.10.0.0/24"
      az_count        = 2
      inspection_flow = "north-south"

      aws_network_firewall = {
        name       = "ANFW-us-west-2"
        policy_arn = aws_networkfirewall_firewall_policy.oregon_anfw_policy.arn
      }

      subnets = {
        public          = { netmask = 28 }
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }

    shared_services = {
      name       = "shared-services-vpc-us-west-2"
      cidr_block = "10.20.0.0/24"
      az_count   = 2

      subnets = {
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }
  }

  spoke_vpcs = {
    prod = { for k, v in module.oregon_spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      } if var.oregon_spoke_vpcs[k].type == "prod"
    }
    nonprod = { for k, v in module.oregon_spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      } if var.oregon_spoke_vpcs[k].type == "nonprod"
    }
  }
}

# Spoke VPCs
module "oregon_spoke_vpcs" {
  for_each = var.oregon_spoke_vpcs
  providers = {
    aws   = aws.awsoregon
    awscc = awscc.awsccoregon
  }

  source  = "aws-ia/vpc/aws"
  version = "= 3.0.1"

  name       = "${each.key}-us-west-2"
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = module.hub_spoke_oregon.transit_gateway.id
  transit_gateway_routes = {
    private = "0.0.0.0/0"
  }

  subnets = {
    private = {
      name_prefix = "private"
      cidrs       = each.value.private_subnet_cidrs
    }
    transit_gateway = {
      name_prefix                                     = "transit_gateway"
      cidrs                                           = each.value.tgw_subnet_cidrs
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }

  tags = {
    env = each.value.type
  }
}

# Managed prefix list (Oregon Region)
resource "aws_ec2_managed_prefix_list" "oregon_network" {
  provider = aws.awsoregon

  name           = "Oregon CIDRs"
  address_family = "IPv4"
  max_entries    = length(var.oregon_spoke_vpcs)
}

resource "aws_ec2_managed_prefix_list_entry" "oregon_entry" {
  for_each = var.oregon_spoke_vpcs
  provider = aws.awsoregon

  cidr           = each.value.cidr_block
  description    = "${each.value.type}-${each.key}"
  prefix_list_id = aws_ec2_managed_prefix_list.oregon_network.id
}

# SSM VPC Endpoints (in Shared Services VPC)
module "oregon_vpc_endpoints" {
  source = "./modules/vpc_endpoints"
  providers = {
    aws = aws.awsoregon
  }

  identifier               = var.identifier
  vpc_name                 = "shared_services-us-west-2"
  vpc_id                   = module.hub_spoke_oregon.central_vpcs["shared_services"].vpc_attributes.id
  vpc_subnets              = values({ for k, v in module.hub_spoke_oregon.central_vpcs["shared_services"].private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  endpoints_security_group = local.oregon.security_groups.endpoints
  endpoints_service_names  = local.oregon.endpoint_service_names
}

# EC2 Instances (in each Spoke VPC)
module "oregon_compute" {
  for_each = module.oregon_spoke_vpcs
  source   = "./modules/compute"
  providers = {
    aws = aws.awsoregon
  }

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "private" })
  number_azs               = var.oregon_spoke_vpcs[each.key].number_azs
  instance_type            = var.oregon_spoke_vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
  ec2_security_group       = local.oregon.security_groups.instance
}

# Private Hosted Zones
module "oregon_phz" {
  source = "./modules/phz"
  providers = {
    aws = aws.awsoregon
  }

  vpc_ids                = { for k, v in module.oregon_spoke_vpcs : k => v.vpc_attributes.id }
  endpoint_dns           = module.oregon_vpc_endpoints.endpoint_dns
  endpoint_service_names = local.oregon.endpoint_service_names
}

# # ---------- RESOURCES TO CREATE IN STOCKHOLM (eu-north-1) ----------

# Hub and Spoke architecture
module "hub_spoke_stockholm" {
  providers = {
    aws   = aws.awsstockholm
    awscc = awscc.awsccstockholm
  }

  source  = "aws-ia/network-hubandspoke/aws"
  version = "1.0.1"

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-eu-north-1"
    description     = "AWS Transit Gateway - eu-north-1"
    amazon_side_asn = var.transit_gateway_asn.stockholm
  }

  network_definition = {
    type  = "PREFIX_LIST"
    value = aws_ec2_managed_prefix_list.stockholm_network.id
  }

  central_vpcs = {
    inspection = {
      name            = "inspection-vpc-eu-north-1"
      cidr_block      = "10.10.0.0/24"
      az_count        = 2
      inspection_flow = "north-south"

      aws_network_firewall = {
        name       = "ANFW-eu-north-1"
        policy_arn = aws_networkfirewall_firewall_policy.stockholm_anfw_policy.arn
      }

      subnets = {
        public          = { netmask = 28 }
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }

    shared_services = {
      name       = "shared-services-vpc-eu-north-1"
      cidr_block = "10.20.0.0/24"
      az_count   = 2

      subnets = {
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }
  }

  spoke_vpcs = {
    prod = { for k, v in module.stockholm_spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      } if var.stockholm_spoke_vpcs[k].type == "prod"
    }
    nonprod = { for k, v in module.stockholm_spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      } if var.stockholm_spoke_vpcs[k].type == "nonprod"
    }
  }
}

# Spoke VPCs
module "stockholm_spoke_vpcs" {
  for_each = var.stockholm_spoke_vpcs
  providers = {
    aws   = aws.awsstockholm
    awscc = awscc.awsccstockholm
  }

  source  = "aws-ia/vpc/aws"
  version = "= 3.0.1"

  name       = "${each.key}-eu-north-1"
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = module.hub_spoke_stockholm.transit_gateway.id
  transit_gateway_routes = {
    private = "0.0.0.0/0"
  }

  subnets = {
    private = {
      name_prefix = "private"
      cidrs       = each.value.private_subnet_cidrs
    }
    transit_gateway = {
      name_prefix                                     = "transit_gateway"
      cidrs                                           = each.value.tgw_subnet_cidrs
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
    }
  }

  tags = {
    env = each.value.type
  }
}

# Managed prefix list (Stockholm Region)
resource "aws_ec2_managed_prefix_list" "stockholm_network" {
  provider = aws.awsstockholm

  name           = "Stockholm CIDRs"
  address_family = "IPv4"
  max_entries    = length(var.stockholm_spoke_vpcs)
}

resource "aws_ec2_managed_prefix_list_entry" "stockholm_entry" {
  for_each = var.stockholm_spoke_vpcs
  provider = aws.awsstockholm

  cidr           = each.value.cidr_block
  description    = "${each.value.type}-${each.key}"
  prefix_list_id = aws_ec2_managed_prefix_list.stockholm_network.id
}

# SSM VPC Endpoints (in Shared Services VPC)
module "stockholm_vpc_endpoints" {
  source = "./modules/vpc_endpoints"
  providers = {
    aws = aws.awsstockholm
  }

  identifier               = var.identifier
  vpc_name                 = "shared_services-eu-north-1"
  vpc_id                   = module.hub_spoke_stockholm.central_vpcs["shared_services"].vpc_attributes.id
  vpc_subnets              = values({ for k, v in module.hub_spoke_stockholm.central_vpcs["shared_services"].private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  endpoints_security_group = local.stockholm.security_groups.endpoints
  endpoints_service_names  = local.stockholm.endpoint_service_names
}

# EC2 Instances (in each Spoke VPC)
module "stockholm_compute" {
  for_each = module.stockholm_spoke_vpcs
  source   = "./modules/compute"
  providers = {
    aws = aws.awsstockholm
  }

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "private" })
  number_azs               = var.stockholm_spoke_vpcs[each.key].number_azs
  instance_type            = var.stockholm_spoke_vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
  ec2_security_group       = local.stockholm.security_groups.instance
}

# Private Hosted Zones
module "stockholm_phz" {
  source = "./modules/phz"
  providers = {
    aws = aws.awsstockholm
  }

  vpc_ids                = { for k, v in module.stockholm_spoke_vpcs : k => v.vpc_attributes.id }
  endpoint_dns           = module.stockholm_vpc_endpoints.endpoint_dns
  endpoint_service_names = local.stockholm.endpoint_service_names
}

# ---------- GLOBAL RESOURCES ----------
# IAM role (EC2 instances to consume AWS Systems Manager)
module "iam" {
  source = "./modules/iam"
  providers = {
    aws = aws.awsoregon
  }

  identifier = var.identifier
}

# ---------- TRANSIT GATEWAY PEERING ----------




# ---------- TRANSIT GATEWAY - CLOUD WAN PEERING ----------

