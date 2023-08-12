# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- root/provider.tf ---

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
  }
}

# Provider definitions
provider "aws" {
  region = var.aws_regions.oregon
  alias  = "awsoregon"
}

provider "aws" {
  region = var.aws_regions.stockholm
  alias  = "awsstockholm"
}