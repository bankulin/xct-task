#variable "admin_role_arn" {
#  # role granted root access to the eks cluster
#  type    = string
#}

variable "devops_role_arn" {
  # role with standard user access to eks cluster
  type    = string
}

variable "eks_version" {
  # eks verison
  type    = string
  default = "1.31"
}

variable "environment" {
  # three letter abbreviation for the environment, e.g. dev/tst/prd etc
  type = string
}

variable "key_name" {
  # ec2 key pair name
  type    = string
}

variable "instance_type" {
  # eks node group instance type
  default = "t3a.small"
  type    = string
}

variable "region" {
  default = "eu-west-1"
  type    = string
}

variable "route53_zone_id" {
  # route53 public hosted zone, used for DNS record creation and certificate manager validation
  type    = string
}

variable "terraform_iam_role_arn" {
  # role assumed by terraform to deploy resources, if left to null it will use the standard AWS credential provider order
  default = null
  type = string
}
