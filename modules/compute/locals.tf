# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/compute/locals.tf ---
locals {
  security_group = {
    name        = "instance_security_group"
    description = "Instance SG (Allowing ICMP and HTTP/HTTPS access)"
    ingress = {
      icmp = {
        description = "Allowing ICMP traffic"
        from        = -1
        to          = -1
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    egress = {
      any = {
        description = "Any traffic"
        from        = 0
        to          = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  }
}