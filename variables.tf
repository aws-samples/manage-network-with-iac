# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/variables.tf ---

# Project identifier
variable "identifier" {
  type        = string
  description = "Project Identifier."

  default = "net324"
}

# AWS Regions to use in this example
variable "aws_regions" {
  type        = map(string)
  description = "AWS regions to spin up resources."

  default = {
    oregon    = "us-west-2"
    stockholm = "eu-north-1"
  }
}

# Amazon Side ASNs to use in the Transit Gateways
variable "transit_gateway_asn" {
  type        = map(string)
  description = "Amazon Side ASNs to apply in the Transit Gateways."

  default = {
    oregon    = 65050
    stockholm = 65051
  }
}

# AWS Region's Supernet CIDR blocks
variable "supernet" {
  type        = map(string)
  description = "AWS Region Supernet CIDR blocks."

  default = {
    oregon    = "10.0.0.0/16"
    stockholm = "10.1.0.0/16"
  }
}

# Definition of the VPCs to create in Oregon Region
variable "oregon_spoke_vpcs" {
  type        = any
  description = "Information about the VPCs to create in us-west-2."

  default = {
    "non-prod" = {
      type                 = "nonprod"
      number_azs           = 2
      cidr_block           = "10.0.1.0/24"
      private_subnet_cidrs = ["10.0.1.0/28", "10.0.1.16/28"]
      tgw_subnet_cidrs     = ["10.0.1.32/28", "10.0.1.48/28"]
      instance_type        = "t2.micro"
    }
    "prod" = {
      type                 = "prod"
      number_azs           = 2
      cidr_block           = "10.0.0.0/24"
      private_subnet_cidrs = ["10.0.0.0/28", "10.0.0.16/28"]
      tgw_subnet_cidrs     = ["10.0.0.32/28", "10.0.0.48/28"]
      instance_type        = "t2.micro"
    }
  }
}

# Definition of the VPCs to create in Stockholm Region
variable "stockholm_spoke_vpcs" {
  type        = any
  description = "Information about the VPCs to create in eu-north-1."

  default = {
    "non-prod" = {
      type                 = "nonprod"
      number_azs           = 2
      cidr_block           = "10.1.1.0/24"
      private_subnet_cidrs = ["10.1.1.0/28", "10.1.1.16/28"]
      tgw_subnet_cidrs     = ["10.1.1.32/28", "10.1.1.48/28"]
      instance_type        = "t2.micro"
    }
    "prod" = {
      type                 = "prod"
      number_azs           = 2
      cidr_block           = "10.1.0.0/24"
      private_subnet_cidrs = ["10.1.0.0/28", "10.1.0.16/28"]
      tgw_subnet_cidrs     = ["10.1.0.32/28", "10.1.0.48/28"]
      instance_type        = "t2.micro"
    }
  }
}