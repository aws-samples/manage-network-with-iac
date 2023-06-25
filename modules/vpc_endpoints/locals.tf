# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc_endpoints/locals.tf ---
locals {
  security_group = {
    name        = "endpoints_sg"
    description = "Security Group for SSM connection"
    ingress = {
      https = {
        description = "Allowing HTTPS"
        from        = 443
        to          = 443
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
      }
    }
    egress = {
      any = {
        description = "Any traffic"
        from        = 0
        to          = 0
        protocol    = "-1"
        cidr_blocks = [var.vpc_cidr]
      }
    }
  }
}