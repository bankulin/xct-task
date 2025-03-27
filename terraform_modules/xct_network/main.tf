terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  dynamic "assume_role" {
    for_each = var.terraform_iam_role_arn != null ? [1] : []
    content {
      role_arn = var.terraform_iam_role_arn
    }
  }
  default_tags {
    tags = {
      environment       = var.environment
      terraform-managed = "true"
    }
  }
}

data "aws_region" "current" {}

locals {
  module_name = replace(basename(abspath(path.module)), "_", "-")
}

# VPC
resource "aws_vpc" "xct_vpc" {
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = true
  instance_tenancy                 = "default"
  tags = {
    Name = "xct-${var.environment}-vpc"
  }
}

resource "aws_ssm_parameter" "vpc" {
  name        = "/terraform/${local.module_name}/vpc-id"
  description = "The VPC ID"
  type        = "String"
  value       = aws_vpc.xct_vpc.id
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name        = "/terraform/${local.module_name}/vpc-cidr"
  description = "The VPC CIDR"
  type        = "String"
  value       = var.vpc_cidr
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.xct_vpc.id
  tags = {
    Name = "xct-${var.environment}-igw"
  }
}

resource "aws_ssm_parameter" "igw" {
  name        = "/terraform/${local.module_name}/igw-id"
  description = "The IGW ID"
  type        = "String"
  value       = aws_internet_gateway.gw.id
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.xct_vpc.id

  tags = {
    Name = "xct-${var.environment}-eigw"
  }
}

resource "aws_ssm_parameter" "eigw" {
  name        = "/terraform/${local.module_name}/eigw-id"
  description = "The egress only igw ID"
  type        = "String"
  value       = aws_egress_only_internet_gateway.eigw.id
}

resource "aws_eip" "nat_gateway_eip" {
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gateway_eip.allocation_id
  depends_on    = [aws_internet_gateway.gw]
  subnet_id     = aws_subnet.public_a_subnet.id
}

resource "aws_ssm_parameter" "nat_gw" {
  name        = "/terraform/${local.module_name}/natgw-id"
  description = "The nat gateway ID"
  type        = "String"
  value       = aws_nat_gateway.nat_gw.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.xct_vpc.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = [aws_route_table.data.id, aws_route_table.private.id, aws_route_table.public.id]
  tags = {
    Name = "xct-${var.environment}-s3-vpce"
  }
}
