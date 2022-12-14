# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- examples/central_shared_services/modules/phz/main.tf ---

# PRIVATE HOSTED ZONES
resource "aws_route53_zone" "private_hosted_zone" {
  for_each = var.endpoint_service_names
  name     = each.value.phz_name

  dynamic "vpc" {
    for_each = var.vpc_ids
    content {
      vpc_id = vpc.value
    }
  }
}

# DNS RECORDS POINTING TO THE VPC ENDPOINTS
resource "aws_route53_record" "endpoint_record" {
  for_each = var.endpoint_service_names
  zone_id  = aws_route53_zone.private_hosted_zone[each.key].id
  name     = ""
  type     = "A"

  alias {
    name                   = var.endpoint_dns[each.key].dns_name
    zone_id                = var.endpoint_dns[each.key].hosted_zone_id
    evaluate_target_health = true
  }
}