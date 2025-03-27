# CONTAINS DATA SOURCES
data "aws_caller_identity" "current" {} # tflint-ignore: terraform_unused_declarations
data "aws_region" "current" {}          # tflint-ignore: terraform_unused_declarations
data "aws_default_tags" "current" {}    # tflint-ignore: terraform_unused_declarations

data "aws_ssm_parameter" "vpc_id" {
  name = "/terraform/xct-network/vpc-id"
}

data "aws_ssm_parameter" "vpc_cidr" {
  name = "/terraform/xct-network/vpc-cidr"
}

data "aws_ssm_parameter" "private_a_subnet" {
  name = "/terraform/xct-network/private-a-subnet-id"
}

data "aws_ssm_parameter" "private_b_subnet" {
  name = "/terraform/xct-network/private-b-subnet-id"
}

data "aws_ssm_parameter" "private_c_subnet" {
  name = "/terraform/xct-network/private-c-subnet-id"
}

data "aws_ssm_parameter" "public_a_subnet" {
  name = "/terraform/xct-network/public-a-subnet-id"
}

data "aws_ssm_parameter" "public_b_subnet" {
  name = "/terraform/xct-network/public-b-subnet-id"
}

data "aws_ssm_parameter" "public_c_subnet" {
  name = "/terraform/xct-network/public-c-subnet-id"
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

data "aws_route53_zone" "route53_zone" {
  zone_id = var.route53_zone_id
}
