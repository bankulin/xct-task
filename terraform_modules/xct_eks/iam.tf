data "aws_iam_policy_document" "eks_role_assume_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "xct-${var.environment}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_role_assume_policy_document.json
}

resource "aws_iam_role_policy_attachment" "managed_policies_attach" {
  for_each = toset(["AmazonEKSClusterPolicy","AmazonEKSVPCResourceController"])
  role       = aws_iam_role.eks_cluster_role.id
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_ssm_parameter" "eks_cluster_role_arn_parameter" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-cluster-role-arn"
  description = "The ARN of the eks cluster role"
  type        = "String"
  value       = aws_iam_role.eks_cluster_role.arn
}

data "aws_iam_policy_document" "eks_node_group_role_assume_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "eks_node_group_iam_policy" {
  name   = "xct-${var.environment}-eks-node-group-iam-policy"
  role   = aws_iam_role.eks_node_group_iam_role.id
  policy = data.aws_iam_policy_document.eks_node_group_role_inline_policy.json
}

resource "aws_iam_role" "eks_node_group_iam_role" {
  name               = "xct-${var.environment}-eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_group_role_assume_policy_document.json
}

resource "aws_iam_role_policy_attachment" "node_group_managed_policies_attach" {
  for_each = toset(["AmazonSSMManagedInstanceCore", "AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy",
                    "AmazonEC2ContainerRegistryReadOnly", "CloudWatchAgentServerPolicy"])
  role       = aws_iam_role.eks_node_group_iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_ssm_parameter" "eks_node_group_iam_role_parameter_arn" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-node-group-role-arn"
  description = "The ARN of the node group IAM role"
  type        = "String"
  value       = aws_iam_role.eks_node_group_iam_role.arn
}

resource "aws_ssm_parameter" "eks_node_group_iam_role_parameter_name" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-node-group-role-name"
  description = "The name of the node group IAM role"
  type        = "String"
  value       = aws_iam_role.eks_node_group_iam_role.name
}


data "aws_iam_policy_document" "eks_node_group_role_inline_policy" {
  statement {
    actions = [
      "ec2:CreateVolume",
      "ec2:CreateTags"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:*:volume/*"
    ]
  }

  statement {
    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:Describe*",
      "ec2:List*"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:ec2:${data.aws_region.current.name}:*:volume/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy_document" "alb_role_assume_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    effect = "Allow"

    principals {
      identifiers = ["pods.eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "alb_role_inline_policy_document" {
  statement {
    effect = "Allow"

    actions = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
    resources = ["*"]
    sid       = "CreateServiceLinkedRoleSid"
  }
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:CreateSecurityGroup"
    ]
    resources = ["*"]

    sid = "wildCardActions"
  }
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }
}

resource "aws_iam_role_policy" "eks_alb_iam_policy" {
  name   = "xct-${var.environment}-eks-alb-iam-policy"
  role   = aws_iam_role.eks_alb_role.id
  policy = data.aws_iam_policy_document.alb_role_inline_policy_document.json
}

resource "aws_iam_role" "eks_alb_role" {
  name               = "xct-${var.environment}-eks-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_role_assume_policy_document.json
}

resource "aws_ssm_parameter" "eks_alb_role_arn_parameter" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-alb-role-arn"
  description = "The ARN of the eks alb role"
  type        = "String"
  value       = aws_iam_role.eks_alb_role.arn
}

resource "aws_eks_pod_identity_association" "alb_pod_identity_association" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.eks_alb_role.arn
}

