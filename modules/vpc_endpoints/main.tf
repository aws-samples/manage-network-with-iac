# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/vpc_endpoints/main.tf ---

# Current AWS Region
data "aws_region" "region" {}

# VPC ENDPOINTS
resource "aws_vpc_endpoint" "endpoint" {
  for_each = toset(var.endpoint_names)

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.region.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpc_subnets
  security_group_ids  = [aws_security_group.endpoints_vpc_sg.id]
  private_dns_enabled = var.private_dns
}

# VPC ENDPOINTS SECURITY GROUPS
resource "aws_security_group" "endpoints_vpc_sg" {
  name        = local.security_group.name
  description = local.security_group.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.security_group.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.security_group.egress
    content {
      description = egress.value.description
      from_port   = egress.value.from
      to_port     = egress.value.to
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.vpc_name}-endpoints-security-group-${var.identifier}"
  }
}