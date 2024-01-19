# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/variables.tf ---

# Project identifier
variable "identifier" {
  description = "Project identifier."
  type        = string

  default = "manage-network-iac"
}

# AWS Regions
variable "aws_regions" {
  description = "AWS Regions to build our environment."
  type        = map(string)

  default = {
    oregon = "us-west-2"
  }
}

# Amazon VPC information
variable "vpcs" {
  description = "VPCs to create."
  type        = any

  default = {
    oregon = {
      vpc1 = {
        number_azs             = 2
        cidr_block             = "10.0.0.0/24"
        workload_subnet_cidrs  = ["10.0.0.0/28", "10.0.0.16/28"]
        endpoints_subnet_cidrs = ["10.0.0.32/28", "10.0.0.48/28"]
        cwan_subnet_cidrs      = ["10.0.0.96/28", "10.0.0.112/28"]
        instance_type          = "t2.micro"
      }
    }
  }
}