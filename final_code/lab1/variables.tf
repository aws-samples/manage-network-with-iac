# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/variables.tf ---

# Project identifier
variable "identifier" {
  description = "Project identifier."
  type        = string

  default = "NET"
}

# AWS Regions
variable "aws_regions" {
  description = "AWS Regions to build our environment."
  type        = map(string)

  default = {
    oregon    = "us-west-2"
    stockholm = "eu-central-1"
  }
}

# Amazon VPC information
variable "vpcs" {
  description = "VPCs to create."
  type        = any

  default = {
    oregon = {
      vpc1 = {
        number_azs                 = 2
        ipv4_cidr_block            = "10.0.0.0/24"
        ipv4_workload_subnet_cidrs = ["10.0.0.0/28", "10.0.0.16/28"]
        ipv4_endpoint_subnet_cidrs = ["10.0.0.32/28", "10.0.0.48/28"]
        instance_type              = "t2.micro"
      }
      vpc2 = {
        number_azs                 = 2
        ipv4_cidr_block            = "10.0.1.0/24"
        ipv4_workload_subnet_cidrs = ["10.0.1.0/28", "10.0.1.16/28"]
        ipv4_endpoint_subnet_cidrs = ["10.0.1.32/28", "10.0.1.48/28"]
        instance_type              = "t2.micro"
      }
      vpc3 = {
        number_azs                 = 2
        ipv4_cidr_block            = "10.0.2.0/24"
        ipv4_workload_subnet_cidrs = ["10.0.2.0/28", "10.0.2.16/28"]
        ipv4_endpoint_subnet_cidrs = ["10.0.2.32/28", "10.0.2.48/28"]
        instance_type              = "t2.micro"
      }
    }
    stockholm = {
      vpc1 = {
        number_azs                 = 2
        ipv4_cidr_block            = "10.1.0.0/24"
        ipv4_workload_subnet_cidrs = ["10.1.0.0/28", "10.1.0.16/28"]
        ipv4_endpoint_subnet_cidrs = ["10.1.0.32/28", "10.1.0.48/28"]
        instance_type              = "t3.micro"
      }
      vpc2 = {
        number_azs                 = 2
        ipv4_cidr_block            = "10.1.1.0/24"
        ipv4_workload_subnet_cidrs = ["10.1.1.0/28", "10.1.1.16/28"]
        ipv4_endpoint_subnet_cidrs = ["10.1.1.32/28", "10.1.1.48/28"]
        instance_type              = "t3.micro"
      }
      vpc3 = {
        number_azs                 = 2
        ipv4_cidr_block            = "10.1.2.0/24"
        ipv4_workload_subnet_cidrs = ["10.1.2.0/28", "10.1.2.16/28"]
        ipv4_endpoint_subnet_cidrs = ["10.1.2.32/28", "10.1.2.48/28"]
        instance_type              = "t3.micro"
      }
    }
  }
}