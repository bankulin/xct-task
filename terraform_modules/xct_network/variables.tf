variable "environment" {
  # three letter abbreviation for the environment, e.g. dev/tst/prd etc
  type = string
}

variable "region" {
  default = "eu-west-1"
  type    = string
}

variable "terraform_iam_role_arn" {
  # role assumed by terraform to deploy resources, if left to null it will use the standard AWS credential provider order
  type = string
  default = null
}

variable "vpc_cidr" {
  # VPC CIDR, should be a /16 network
  default = "10.0.0.0/16"
  type    = string
}
