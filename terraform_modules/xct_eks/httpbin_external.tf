# CONTAINS EXTERNAL HTTPBIN ENDPOINT RESOURCES
resource "aws_lb_target_group" "external_httpbin_tg" {
  name                 = "xct-${var.environment}-external-httpbin-tg"
  deregistration_delay = 0
  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = 25
    unhealthy_threshold = 2
  }
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_ssm_parameter" "external_httpbin_tg_arn_parameter" {
  name        = "/terraform/${var.environment}/${local.module_name}/external-tg-arn"
  description = "The xct httpbin target group arn"
  type        = "String"
  value       = aws_lb_target_group.external_httpbin_tg.arn
}

resource "aws_lb_listener_rule" "external_httpbin_listener_rule" {
  listener_arn = aws_lb_listener.external_eks_alb_http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_httpbin_tg.arn
  }

  condition {
    host_header {
      values = ["httpbin.${data.aws_route53_zone.route53_zone.name}"]
    }
  }
}

resource "aws_route53_record" "httpbin_alias_record" {
  zone_id = var.route53_zone_id
  name    = "httpbin.${data.aws_route53_zone.route53_zone.name}"
  type    = "A"
  alias {
    name                   = aws_lb.external_eks_alb.dns_name
    zone_id                = aws_lb.external_eks_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener_rule" "https_listener_rule" {
  listener_arn = aws_lb_listener.external_eks_alb_https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_httpbin_tg.arn
  }

  condition {
    host_header {
      values = ["httpbin.${data.aws_route53_zone.route53_zone.name}"]
    }
  }
}
