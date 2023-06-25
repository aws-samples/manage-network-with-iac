# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc_endpoints/variables.tf ---

variable "identifier" {
  description = "Project identifier."
  type        = string
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC where the VPC endpoints are created."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the endpoint(s)."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC."
}

variable "vpc_subnets" {
  type        = list(string)
  description = "List of the subnets to place the endpoint(s)."
}

variable "endpoint_names" {
  type        = list(string)
  description = "VPC endpoint service names."
}

variable "private_dns" {
  type        = bool
  description = "Indicating if the Interface endpoint"
}