# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/main.tf ---

# ---------- LOCAL VARIABLES ----------
# VPC endpoint service names
locals {
  endpoint_names = ["ssm", "ssmmessages", "ec2messages"]
}

# ---------- OREGON (us-west-2) ENVIRONMENT ----------
# Amazon VPCs
module "oregon_vpc" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awsoregon }
  for_each  = var.vpcs.oregon

  name                                 = each.key
  cidr_block                           = each.value.ipv4_cidr_block
  vpc_assign_generated_ipv6_cidr_block = true
  az_count                             = each.value.number_azs

  transit_gateway_id = module.oregon_hubspoke.transit_gateway.id
  transit_gateway_routes = {
    workload = "0.0.0.0/0"
  }
  transit_gateway_ipv6_routes = {
    workload = "::/0"
  }

  subnets = {
    workload = {
      cidrs            = each.value.ipv4_workload_subnet_cidrs
      assign_ipv6_cidr = true
    }
    endpoint = {
      cidrs            = each.value.ipv4_endpoint_subnet_cidrs
      assign_ipv6_cidr = true
    }
    transit_gateway = {
      cidrs                                           = each.value.ipv4_tgw_subnet_cidrs
      assign_ipv6_cidr                                = true
      transit_gateway_default_route_table_propagation = false
      transit_gateway_default_route_table_association = false
    }
  }
}

# EC2 instances
module "oregon_compute" {
  source    = "./modules/compute"
  providers = { aws = aws.awsoregon }
  for_each  = module.oregon_vpc

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "workload" })
  number_azs               = var.vpcs.oregon[each.key].number_azs
  instance_type            = var.vpcs.oregon[each.key].instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
}

# VPC endpoints 
module "oregon_central_endpoints" {
  source    = "./modules/vpc_endpoints"
  providers = { aws = aws.awsoregon }

  identifier     = var.identifier
  vpc_name       = "shared-services-vpc"
  vpc_id         = module.oregon_hubspoke.central_vpcs.shared_services.vpc_attributes.id
  vpc_cidr       = "10.0.0.0/16"
  vpc_subnets    = values({ for k, v in module.oregon_hubspoke.central_vpcs.shared_services.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  endpoint_names = local.endpoint_names
  private_dns    = false
}

# Private Hosted Zone (Shared Services VPC endpoints)
module "oregon_phz" {
  source    = "./modules/phz"
  providers = { aws = aws.awsoregon }

  vpc_ids                = { for k, v in module.oregon_vpc : k => v.vpc_attributes.id }
  endpoint_dns           = module.oregon_central_endpoints.endpoint_dns
  endpoint_service_names = local.endpoint_names
}

# AWS Hub and Spoke environment
module "oregon_hubspoke" {
  source    = "git::https://github.com/pablo19sc/terraform-aws-network-hubandspoke"
  providers = { aws = aws.awsoregon }

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-oregon"
    description     = "Transit Gateway - Oregon"
    amazon_side_asn = 65000
  }
  network_definition = {
    type  = "CIDR"
    value = "10.0.0.0/16"
  }

  central_vpcs = {
    shared_services = {
      name       = "shared-services-vpc"
      cidr_block = var.central_vpcs.oregon.shared_services.ipv4_cidr_block
      az_count   = var.central_vpcs.oregon.shared_services.number_azs

      subnets = {
        endpoints       = { netmask = var.central_vpcs.oregon.shared_services.ipv4_endpoint_subnet_netmask }
        transit_gateway = { netmask = var.central_vpcs.oregon.shared_services.ipv4_tgw_subnet_netmask }
      }
    }
  }

  spoke_vpcs = {
    routing_domains = ["prod", "nonprod"]
    number_vpcs     = length(var.vpcs.oregon)
    vpc_information = { for k, v in module.oregon_vpc : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      routing_domain                = var.vpcs.oregon[k].routing_domain
    } }
  }
}

# ---------- STOCKHOLM (us-west-2) ENVIRONMENT ----------
# Amazon VPCs
module "stockholm_vpc" {
  source    = "aws-ia/vpc/aws"
  version   = "4.3.0"
  providers = { aws = aws.awsstockholm }
  for_each  = var.vpcs.stockholm

  name                                 = each.key
  cidr_block                           = each.value.ipv4_cidr_block
  vpc_assign_generated_ipv6_cidr_block = true
  az_count                             = each.value.number_azs

  transit_gateway_id = module.stockholm_hubspoke.transit_gateway.id
  transit_gateway_routes = {
    workload = "0.0.0.0/0"
  }
  transit_gateway_ipv6_routes = {
    workload = "::/0"
  }

  subnets = {
    workload = {
      cidrs            = each.value.ipv4_workload_subnet_cidrs
      assign_ipv6_cidr = true
    }
    endpoint = {
      cidrs            = each.value.ipv4_endpoint_subnet_cidrs
      assign_ipv6_cidr = true
    }
    transit_gateway = {
      cidrs                                           = each.value.ipv4_tgw_subnet_cidrs
      assign_ipv6_cidr                                = true
      transit_gateway_default_route_table_propagation = false
      transit_gateway_default_route_table_association = false
    }
  }
}

# EC2 instances
module "stockholm_compute" {
  source    = "./modules/compute"
  providers = { aws = aws.awsstockholm }
  for_each  = module.stockholm_vpc

  identifier               = var.identifier
  vpc_name                 = each.key
  vpc_id                   = each.value.vpc_attributes.id
  vpc_subnets              = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "workload" })
  number_azs               = var.vpcs.oregon[each.key].number_azs
  instance_type            = var.vpcs.oregon[each.key].instance_type
  ec2_iam_instance_profile = module.iam.ec2_iam_instance_profile
}

# VPC endpoints 
module "stockholm_central_endpoints" {
  source    = "./modules/vpc_endpoints"
  providers = { aws = aws.awsstockholm }

  identifier     = var.identifier
  vpc_name       = "shared-services-vpc"
  vpc_id         = module.stockholm_hubspoke.central_vpcs.shared_services.vpc_attributes.id
  vpc_cidr       = "10.1.0.0/16"
  vpc_subnets    = values({ for k, v in module.stockholm_hubspoke.central_vpcs.shared_services.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  endpoint_names = local.endpoint_names
  private_dns    = false
}

# Private Hosted Zone (Shared Services VPC endpoints)
module "stockholm_phz" {
  source    = "./modules/phz"
  providers = { aws = aws.awsstockholm }

  vpc_ids                = { for k, v in module.stockholm_vpc : k => v.vpc_attributes.id }
  endpoint_dns           = module.stockholm_central_endpoints.endpoint_dns
  endpoint_service_names = local.endpoint_names
}

# AWS Hub and Spoke environment
module "stockholm_hubspoke" {
  source    = "git::https://github.com/pablo19sc/terraform-aws-network-hubandspoke"
  providers = { aws = aws.awsstockholm }

  identifier = var.identifier
  transit_gateway_attributes = {
    name            = "tgw-stockholm"
    description     = "Transit Gateway - Stockholm"
    amazon_side_asn = 65001
  }
  network_definition = {
    type  = "CIDR"
    value = "10.1.0.0/16"
  }

  central_vpcs = {
    shared_services = {
      name       = "shared-services-vpc"
      cidr_block = var.central_vpcs.stockholm.shared_services.ipv4_cidr_block
      az_count   = var.central_vpcs.stockholm.shared_services.number_azs

      subnets = {
        endpoints       = { netmask = var.central_vpcs.stockholm.shared_services.ipv4_endpoint_subnet_netmask }
        transit_gateway = { netmask = var.central_vpcs.stockholm.shared_services.ipv4_tgw_subnet_netmask }
      }
    }
  }

  spoke_vpcs = {
    routing_domains = ["prod", "nonprod"]
    number_vpcs     = length(var.vpcs.stockholm)
    vpc_information = { for k, v in module.stockholm_vpc : k => {
      vpc_id                        = v.vpc_attributes.id
      transit_gateway_attachment_id = v.transit_gateway_attachment_id
      routing_domain                = var.vpcs.stockholm[k].routing_domain
    } }
  }
}

# ---------- GLOBAL RESOURCES ----------
# IAM resources
module "iam" {
  source    = "./modules/iam"
  providers = { aws = aws.awsoregon }

  identifier = var.identifier
}