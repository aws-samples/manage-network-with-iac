# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- networking_account/variables.tf ---

# Project identifier
variable "identifier" {
  type        = string
  description = "Project Identifier."

  default = "manage-network-iac-networking"
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

# Inspection VPC
variable "inspection_vpc" {
  description = "Inspection VPC parameters."
  type        = map(any)

  default = {
    number_azs               = 2
    cidr_block               = "10.100.0.0/24"
    public_subnet_netmask    = 28
    endpoints_subnet_netmask = 28
    tgw_subnet_netmask       = 28
    cwan_subnet_netmask      = 28
  }
}

# Routing domains
variable "routing_domains" {
  description = "Routing domains."
  type        = list(string)

  default = ["prod", "nonprod"]
}