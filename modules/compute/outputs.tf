# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- examples/central_shared_services/modules/compute/outputs.tf ---

output "ec2_instances" {
  value       = aws_instance.ec2_instance
  description = "List of instances created."
}

output "eic_endpoint" {
  value       = aws_ec2_instance_connect_endpoint.eic_endpoint.id
  description = "EC2 Instance Connect Endpoint."
}