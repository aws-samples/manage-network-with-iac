# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/outputs.tf ---

output "vpcs" {
  description = "VPCs created."
  value = {
    oregon    = { for k, v in module.oregon_vpc : k => v.vpc_attributes.id }
    stockholm = { for k, v in module.stockholm_vpc : k => v.vpc_attributes.id }
  }
}