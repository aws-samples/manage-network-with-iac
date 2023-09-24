# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modulest/prefix_lists/outputs.tf ---

output "oregon_prefix_lists" {
  description = "Oregon (us-west-2) prefix lists."
  value = {
    prod    = aws_ec2_managed_prefix_list.oregon_prod_ipv4.id
    nonprod = aws_ec2_managed_prefix_list.oregon_nonprod_ipv4.id
  }
}

output "tokyo_prefix_lists" {
  description = "Tokyo (ap-northeast-1) prefix lists."
  value = {
    prod    = aws_ec2_managed_prefix_list.tokyo_prod_ipv4.id
    nonprod = aws_ec2_managed_prefix_list.tokyo_nonprod_ipv4.id
  }
}