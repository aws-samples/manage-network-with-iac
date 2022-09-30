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
    north_virginia = "us-east-1"
    ireland        = "eu-west-1"
  }
}

# Amazon Side ASNs to use in the Transit Gateways
variable "transit_gateway_asn" {
  type = map(string)
  description = "Amazon Side ASNs to apply in the Transit Gateways."

  default = {
    north_virginia = 65050
    ireland = 65051
  }
} 

# Definition of the VPCs to create in N. Virginia Region
variable "nvirginia_spoke_vpcs" {
  type        = any
  description = "Information about the VPCs to create in us-east-1."

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

# Definition of the VPCs to create in Ireland Region
variable "ireland_spoke_vpcs" {
  type        = any
  description = "Information about the VPCs to create in eu-west-1."

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