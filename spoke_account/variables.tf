# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- spoke_account/variables.tf ---

# Project identifier
variable "identifier" {
  type        = string
  description = "Project Identifier."

  default = "manage-network-iac-spoke"
}

# AWS Regions to use in this example
variable "aws_regions" {
  type        = map(string)
  description = "AWS regions to spin up resources."

  default = {
    oregon  = "us-west-2"
    ireland = "eu-west-1"
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
      instance_type        = "t2.micro"
    }
    "prod" = {
      type                 = "prod"
      number_azs           = 2
      cidr_block           = "10.0.0.0/24"
      private_subnet_cidrs = ["10.0.0.0/28", "10.0.0.16/28"]
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
      instance_type        = "t2.micro"
    }
    "prod" = {
      type                 = "prod"
      number_azs           = 2
      cidr_block           = "10.1.0.0/24"
      private_subnet_cidrs = ["10.1.0.0/28", "10.1.0.16/28"]
      instance_type        = "t2.micro"
    }
  }
}