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

  subnets = {
    workload = {
      cidrs            = each.value.ipv4_workload_subnet_cidrs
      assign_ipv6_cidr = true
    }
    endpoint = {
      cidrs            = each.value.ipv4_endpoint_subnet_cidrs
      assign_ipv6_cidr = true
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
module "oregon_vpc_endpoints" {
  source    = "./modules/vpc_endpoints"
  providers = { aws = aws.awsoregon }
  for_each  = module.oregon_vpc

  identifier     = var.identifier
  vpc_name       = each.key
  vpc_id         = each.value.vpc_attributes.id
  vpc_cidr       = var.vpcs.oregon[each.key].ipv4_cidr_block
  vpc_subnets    = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoint" })
  endpoint_names = local.endpoint_names
  private_dns    = true
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

  subnets = {
    workload = {
      cidrs            = each.value.ipv4_workload_subnet_cidrs
      assign_ipv6_cidr = true
    }
    endpoint = {
      cidrs            = each.value.ipv4_endpoint_subnet_cidrs
      assign_ipv6_cidr = true
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
module "stockholm_vpc_endpoints" {
  source    = "./modules/vpc_endpoints"
  providers = { aws = aws.awsstockholm }
  for_each  = module.stockholm_vpc

  identifier     = var.identifier
  vpc_name       = each.key
  vpc_id         = each.value.vpc_attributes.id
  vpc_cidr       = var.vpcs.oregon[each.key].ipv4_cidr_block
  vpc_subnets    = values({ for k, v in each.value.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoint" })
  endpoint_names = local.endpoint_names
  private_dns    = true
}

# ---------- GLOBAL RESOURCES ----------
# IAM resources
module "iam" {
  source    = "./modules/iam"
  providers = { aws = aws.awsoregon }

  identifier = var.identifier
}