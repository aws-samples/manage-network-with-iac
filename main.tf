# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# ---------- RESOURCES TO CREATE IN N. VIRGINIA (us-east-1) ----------

# Hub and Spoke architecture
module "hub_spoke_nvirginia" {
  source = "git::https://github.com/pablo19sc/terraform-aws-network-hubandspoke"
  providers = {
    aws   = aws.awsnvirginia
    awscc = awscc.awsccnvirginia
  }

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-us-east-1"
    description     = "AWS Transit Gateway - us-east-1"
    amazon_side_asn = var.transit_gateway_asn.north_virginia
  }

  network_definition = {
    type  = "PREFIX_LIST"
    value = aws_ec2_managed_prefix_list.nvirginia_network.id
  }

  central_vpcs = {
    inspection = {
      name            = "inspection-vpc-us-east-1"
      cidr_block      = "10.10.0.0/24"
      az_count        = 2
      inspection_flow = "north-south"

      aws_network_firewall = {
        name       = "ANFW-us-east-1"
        policy_arn = aws_networkfirewall_firewall_policy.nvirginia_anfw_policy.arn
      }

      subnets = {
        public          = { netmask = 28 }
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }

    shared_services = {
      name       = "shared-services-vpc-us-east-1"
      cidr_block = "10.20.0.0/24"
      az_count   = 2

      subnets = {
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }
  }

  spoke_vpcs = {
    prod = { for k, v in module.nvirginia_spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      } if var.nvirginia_spoke_vpcs[k].type == "prod"
    }
    nonprod = { for k, v in module.nvirginia_spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      } if var.nvirginia_spoke_vpcs[k].type == "nonprod"
    }
  }
}

# Spoke VPCs
module "nvirginia_spoke_vpcs" {
  for_each = var.nvirginia_spoke_vpcs
  source   = "aws-ia/vpc/aws"
  version  = "= 3.0.0"
  providers = {
    aws   = aws.awsnvirginia
    awscc = awscc.awsccnvirginia
  }

  name       = "${each.key}-us-east-1"
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = module.hub_spoke_nvirginia.transit_gateway.id
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

# Managed prefix list (N. Virginia Region)
resource "aws_ec2_managed_prefix_list" "nvirginia_network" {
  provider = aws.awsnvirginia

  name           = "N. Virginia CIDRs"
  address_family = "IPv4"
  max_entries    = length(var.nvirginia_spoke_vpcs)
}

resource "aws_ec2_managed_prefix_list_entry" "nvirginia_entry" {
  for_each = var.nvirginia_spoke_vpcs
  provider = aws.awsnvirginia

  cidr           = each.value.cidr_block
  description    = "${each.value.type}-${each.key}"
  prefix_list_id = aws_ec2_managed_prefix_list.nvirginia_network.id
}

# SSM VPC Endpoints (in Shared Services VPC)
module "nvirginia_vpc_endpoints" {
  source = "./modules/vpc_endpoints"
  providers = {
    aws = aws.awsnvirginia
  }

  identifier               = var.identifier
  vpc_name                 = "shared_services-us-east-1"
  vpc_id                   = module.hub_spoke_nvirginia.central_vpcs["shared_services"].vpc_attributes.id
  vpc_subnets              = values({ for k, v in module.hub_spoke_nvirginia.central_vpcs["shared_services"].private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  endpoints_security_group = local.north_virginia.security_groups.endpoints
  endpoints_service_names  = local.north_virginia.endpoint_service_names
}

# EC2 Instances (in each Spoke VPC)
module "nvirginia_compute" {
  for_each = module.nvirginia_spoke_vpcs
  source   = "./modules/compute"
  providers = {
    aws = aws.awsnvirginia
  }

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "private" })
  number_azs               = var.nvirginia_spoke_vpcs[each.key].number_azs
  instance_type            = var.nvirginia_spoke_vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
  ec2_security_group       = local.north_virginia.security_groups.instance
}

# Private Hosted Zones
module "nvirginia_phz" {
  source = "./modules/phz"
  providers = {
    aws = aws.awsnvirginia
  }

  vpc_ids                = { for k, v in module.nvirginia_spoke_vpcs : k => v.vpc_attributes.id }
  endpoint_dns           = module.nvirginia_vpc_endpoints.endpoint_dns
  endpoint_service_names = local.north_virginia.endpoint_service_names
}

# # ---------- RESOURCES TO CREATE IN IRELAND (eu-west-1) ----------

# Hub and Spoke architecture
module "hub_spoke_ireland" {
  source = "git::https://github.com/pablo19sc/terraform-aws-network-hubandspoke"
  providers = {
    aws   = aws.awsireland
    awscc = awscc.awsccireland
  }

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-eu-west-1"
    description     = "AWS Transit Gateway - eu-west-1"
    amazon_side_asn = var.transit_gateway_asn.ireland
  }

  network_definition = {
    type  = "PREFIX_LIST"
    value = aws_ec2_managed_prefix_list.ireland_network.id
  }

  central_vpcs = {
    inspection = {
      name            = "inspection-vpc-eu-west-1"
      cidr_block      = "10.10.0.0/24"
      az_count        = 2
      inspection_flow = "north-south"

      aws_network_firewall = {
        name       = "ANFW-eu-west-1"
        policy_arn = aws_networkfirewall_firewall_policy.ireland_anfw_policy.arn
      }

      subnets = {
        public          = { netmask = 28 }
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }

    shared_services = {
      name       = "shared-services-vpc-eu-west-1"
      cidr_block = "10.20.0.0/24"
      az_count   = 2

      subnets = {
        endpoints       = { netmask = 28 }
        transit_gateway = { netmask = 28 }
      }
    }
  }

  spoke_vpcs = {
    prod = { for k, v in module.ireland_spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      } if var.ireland_spoke_vpcs[k].type == "prod"
    }
    nonprod = { for k, v in module.ireland_spoke_vpcs : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      } if var.ireland_spoke_vpcs[k].type == "nonprod"
    }
  }
}

# Spoke VPCs
module "ireland_spoke_vpcs" {
  for_each = var.ireland_spoke_vpcs
  source   = "aws-ia/vpc/aws"
  version  = "= 3.0.0"
  providers = {
    aws   = aws.awsireland
    awscc = awscc.awsccireland
  }

  name       = "${each.key}-eu-west-1"
  cidr_block = each.value.cidr_block
  az_count   = each.value.number_azs

  transit_gateway_id = module.hub_spoke_ireland.transit_gateway.id
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

# Managed prefix list (N. Virginia Region)
resource "aws_ec2_managed_prefix_list" "ireland_network" {
  provider = aws.awsireland

  name           = "N. Virginia CIDRs"
  address_family = "IPv4"
  max_entries    = length(var.ireland_spoke_vpcs)
}

resource "aws_ec2_managed_prefix_list_entry" "ireland_entry" {
  for_each = var.ireland_spoke_vpcs
  provider = aws.awsireland

  cidr           = each.value.cidr_block
  description    = "${each.value.type}-${each.key}"
  prefix_list_id = aws_ec2_managed_prefix_list.ireland_network.id
}

# SSM VPC Endpoints (in Shared Services VPC)
module "ireland_vpc_endpoints" {
  source = "./modules/vpc_endpoints"
  providers = {
    aws = aws.awsireland
  }

  identifier               = var.identifier
  vpc_name                 = "shared_services-eu-west-1"
  vpc_id                   = module.hub_spoke_ireland.central_vpcs["shared_services"].vpc_attributes.id
  vpc_subnets              = values({ for k, v in module.hub_spoke_ireland.central_vpcs["shared_services"].private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  endpoints_security_group = local.ireland.security_groups.endpoints
  endpoints_service_names  = local.ireland.endpoint_service_names
}

# EC2 Instances (in each Spoke VPC)
module "ireland_compute" {
  for_each = module.ireland_spoke_vpcs
  source   = "./modules/compute"
  providers = {
    aws = aws.awsireland
  }

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "private" })
  number_azs               = var.ireland_spoke_vpcs[each.key].number_azs
  instance_type            = var.ireland_spoke_vpcs[each.key].instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
  ec2_security_group       = local.ireland.security_groups.instance
}

# Private Hosted Zones
module "ireland_phz" {
  source = "./modules/phz"
  providers = {
    aws = aws.awsireland
  }

  vpc_ids                = { for k, v in module.ireland_spoke_vpcs : k => v.vpc_attributes.id }
  endpoint_dns           = module.ireland_vpc_endpoints.endpoint_dns
  endpoint_service_names = local.ireland.endpoint_service_names
}

# ---------- GLOBAL RESOURCES ----------
# IAM role (EC2 instances to consume AWS Systems Manager)
module "iam" {
  source = "./modules/iam"
  providers = {
    aws = aws.awsnvirginia
  }

  identifier = var.identifier
}

# ---------- TRANSIT GATEWAY PEERING ----------




# ---------- TRANSIT GATEWAY - CLOUD WAN PEERING ----------

