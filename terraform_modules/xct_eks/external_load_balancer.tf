# CONTAINS RESOURCES RELATED TO THE EKS EXTERNAL LOAD BALANCER
resource "aws_security_group" "external_eks_alb_sg" {
  name        = "xct-${var.environment}-external-eks-alb-sg"
  description = "Security group for external xct eks application load balancers"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ssm_parameter" "external_eks_alb_sg" {
  name        = "/terraform/${var.environment}/${local.module_name}/external-eks-alb-sg"
  description = "The sg of the external eks alb"
  type        = "String"
  value       = aws_security_group.external_eks_alb_sg.id
}

resource "aws_lb" "external_eks_alb" {
  name               = "xct-${var.environment}-external-eks-alb"
  idle_timeout       = 1200
  ip_address_type    = "dualstack"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_eks_alb_sg.id]
  subnets = [
    data.aws_ssm_parameter.public_a_subnet.value,
    data.aws_ssm_parameter.public_b_subnet.value,
    data.aws_ssm_parameter.public_c_subnet.value
  ]
}

resource "aws_lb_target_group" "external_eks_default_tg" {
  name     = "xct-${var.environment}-eks-default-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_lb_listener" "external_eks_alb_http_listener" {
  load_balancer_arn = aws_lb.external_eks_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_eks_default_tg.arn
  }
}

resource "aws_lb_listener" "external_eks_alb_https_listener" {
  load_balancer_arn = aws_lb.external_eks_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_eks_default_tg.arn
  }
}

resource "aws_lb_listener_certificate" "certificate" {
  listener_arn    = aws_lb_listener.external_eks_alb_https_listener.arn
  certificate_arn = aws_acm_certificate.cert.arn
}

resource "aws_route53_record" "eks_alb_dns_record" {
  zone_id = var.route53_zone_id
  name    = "xct-eks.${var.environment}"
  type    = "A"

  alias {
    name                   = aws_lb.external_eks_alb.dns_name
    zone_id                = aws_lb.external_eks_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_ssm_parameter" "external_eks_alb_http_listener_arn" {
  name        = "/terraform/${var.environment}/${local.module_name}/external-eks-alb-http-listener-arn"
  description = "The ARN of http listener"
  type        = "String"
  value       = aws_lb_listener.external_eks_alb_http_listener.arn
}

resource "aws_ssm_parameter" "eks_alb_dns_record_fqdn" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-alb-dns-record-fqdn"
  description = "The alb fqdn"
  type        = "String"
  value       = aws_route53_record.eks_alb_dns_record.alias[0].name
}

resource "aws_ssm_parameter" "eks_alb_dns_zone_id" {
  name        = "/terraform/${var.environment}/${local.module_name}/eks-alb-dns-zone-id"
  description = "The alb zone ID"
  type        = "String"
  value       = aws_lb.external_eks_alb.zone_id
}

