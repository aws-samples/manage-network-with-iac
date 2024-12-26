# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- spoke_account/variables.tf ---

# Project identifier
variable "identifier" {
  type        = string
  description = "Project Identifier."

  default = "manage-network-iac-spoke"
}

# AWS Regions to use
variable "aws_regions" {
  type        = map(string)
  description = "AWS regions to spin up resources."

  default = {
    oregon  = "us-west-2"
    ireland = "eu-west-1"
    sydney  = "ap-southeast-2"
  }
}

# Definition of the VPCs to create in Oregon Region
variable "oregon_spoke_vpcs" {
  type        = any
  description = "Information about the VPCs to create in us-west-2."

  default = {
    "prod" = {
      type                  = "prod"
      number_azs            = 2
      cidr_block            = "10.0.0.0/24"
      private_subnet_cidrs  = ["10.0.0.0/28", "10.0.0.16/28"]
      endpoint_subnet_cidrs = ["10.0.0.32/28", "10.0.0.48/28"]
      tgw_subnet_cidrs      = ["10.0.0.64/28", "10.0.0.80/28"]
      cwan_subnet_cidrs     = ["10.0.0.96/28", "10.0.0.112/28"]
      instance_type         = "t2.micro"
    }
    "nonprod" = {
      type                  = "nonprod"
      number_azs            = 2
      cidr_block            = "10.0.1.0/24"
      private_subnet_cidrs  = ["10.0.1.0/28", "10.0.1.16/28"]
      endpoint_subnet_cidrs = ["10.0.1.32/28", "10.0.1.48/28"]
      tgw_subnet_cidrs      = ["10.0.1.64/28", "10.0.1.80/28"]
      cwan_subnet_cidrs     = ["10.0.1.96/28", "10.0.1.112/28"]
      instance_type         = "t2.micro"
    }
  }
}

# Definition of the VPCs to create in Ireland Region
variable "ireland_spoke_vpcs" {
  type        = any
  description = "Information about the VPCs to create in eu-west-1."

  default = {
    "prod" = {
      type                  = "prod"
      number_azs            = 2
      cidr_block            = "10.1.0.0/24"
      private_subnet_cidrs  = ["10.1.0.0/28", "10.1.0.16/28"]
      endpoint_subnet_cidrs = ["10.1.0.32/28", "10.1.0.48/28"]
      tgw_subnet_cidrs      = ["10.1.0.64/28", "10.1.0.80/28"]
      cwan_subnet_cidrs     = ["10.1.0.96/28", "10.1.0.112/28"]
      instance_type         = "t2.micro"
    }
    "nonprod" = {
      type                  = "nonprod"
      number_azs            = 2
      cidr_block            = "10.1.1.0/24"
      private_subnet_cidrs  = ["10.1.1.0/28", "10.1.1.16/28"]
      endpoint_subnet_cidrs = ["10.1.1.32/28", "10.1.1.48/28"]
      tgw_subnet_cidrs      = ["10.1.1.64/28", "10.1.1.80/28"]
      cwan_subnet_cidrs     = ["10.1.1.96/28", "10.1.1.112/28"]
      instance_type         = "t2.micro"
    }
  }
}

# Definition of the VPCs to create in Sydney Region
variable "sydney_spoke_vpcs" {
  type        = any
  description = "Information about the VPCs to create in ap-southeast-2."

  default = {
    "prod" = {
      type                  = "prod"
      number_azs            = 2
      cidr_block            = "10.2.0.0/24"
      private_subnet_cidrs  = ["10.2.0.0/28", "10.2.0.16/28"]
      endpoint_subnet_cidrs = ["10.2.0.32/28", "10.2.0.48/28"]
      cwan_subnet_cidrs     = ["10.2.0.64/28", "10.2.0.80/28"]
      instance_type         = "t2.micro"
    }
    "nonprod" = {
      type                  = "nonprod"
      number_azs            = 2
      cidr_block            = "10.2.1.0/24"
      private_subnet_cidrs  = ["10.2.1.0/28", "10.2.1.16/28"]
      endpoint_subnet_cidrs = ["10.2.1.32/28", "10.2.1.48/28"]
      cwan_subnet_cidrs     = ["10.2.1.64/28", "10.2.1.80/28"]
      instance_type         = "t2.micro"
    }
  }
}