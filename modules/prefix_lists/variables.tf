# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modulest/prefix_lists/variables.tf ---

variable "oregon_vpcs" {
  description = "Oregon (us-west-2) VPC information."
  type        = map(any)
}

variable "tokyo_vpcs" {
  description = "Tokyo (ap-northeast-1) VPC information."
  type        = map(any)
}

