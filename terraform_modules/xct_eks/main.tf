# CONTAINS TERRAFORM CONFIGURATION AND EKS CLUSTER RESOURCES
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
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

locals {
  module_name = replace(basename(abspath(path.module)), "_", "-")
}

resource "aws_cloudwatch_log_group" "eks_cluster_log_group" {
  name              = "/aws/eks/xct-${var.environment}-eks-cluster/cluster"
  retention_in_days = 7
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "xct-${var.environment}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      data.aws_ssm_parameter.private_a_subnet.value,
      data.aws_ssm_parameter.private_b_subnet.value,
      data.aws_ssm_parameter.private_c_subnet.value
    ]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role.eks_cluster_role
  ]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.eks_cluster.id}"
  }

  version = var.eks_version
}

resource "aws_ssm_parameter" "eks_cluster_name" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-cluster-name"
  description = "The name of the eks cluster"
  type        = "String"
  value       = aws_eks_cluster.eks_cluster.id
}

resource "aws_ssm_parameter" "eks_cluster_endpoint" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-cluster-endpoint"
  description = "The endpoint of the eks cluster"
  type        = "String"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

resource "aws_launch_template" "eks_node_group_launch_template" {
  name = "xct-${var.environment}-eks-node-group-launch-template"

  instance_type = var.instance_type

  key_name = var.key_name

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "xct-${var.environment}-eks-node-group"
      type = "eks"
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.18.3-eksbuild.2"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
    }
  })
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_node_group" "xct_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "xct-${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_iam_role.arn
  launch_template {
    id      = aws_launch_template.eks_node_group_launch_template.id
    version = aws_launch_template.eks_node_group_launch_template.latest_version
  }

  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  subnet_ids = [
    data.aws_ssm_parameter.private_a_subnet.value,
    data.aws_ssm_parameter.private_b_subnet.value,
    data.aws_ssm_parameter.private_c_subnet.value
  ]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  tags = {
    Name = "xct-${var.environment}-node-group"
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_addon.vpc_cni,
    aws_iam_role.eks_node_group_iam_role
  ]
}

resource "aws_eks_access_entry" "devops_role_access_entry" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = var.devops_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "devops_role_policy_association" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.devops_role_arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_addon" "eks_pod_identity_addon" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = "v1.3.2-eksbuild.2"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_cluster.eks_cluster]
}

resource "aws_ssm_parameter" "eks_cluster_sg" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-cluster-sg"
  description = "The sg id of eks cluster"
  type        = "String"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${data.aws_route53_zone.route53_zone.name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}
