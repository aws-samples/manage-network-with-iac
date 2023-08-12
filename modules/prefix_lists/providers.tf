# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modulest/prefix_lists/providers.tf ---

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.67.0"
      configuration_aliases = [aws.awsoregon, aws.awsstockholm]
    }
  }
}
