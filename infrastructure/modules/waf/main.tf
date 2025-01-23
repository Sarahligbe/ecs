resource "aws_wafv2_web_acl" "app_waf" {
  name        = "${var.ecs_cluster_name}-waf"
  description = "WAF for ECS application"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "RateLimitMetric"
      sampled_requests_enabled  = true
    }
  }

  rule {
    name     = "CaptchaRule"
    priority = 2

    override_action {
      none {}
    }

    statement {
      and_statement {
        statement {
          rate_based_statement {
            limit              = var.captcha_limit
            aggregate_key_type = "IP"
          }
        }
      }
    }

    action {
      challenge {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "CaptchaMetric"
      sampled_requests_enabled  = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "${var.ecs_cluster_name}WAFMetrics"
    sampled_requests_enabled  = true
  }
}

resource "aws_wafv2_web_acl_association" "app_waf_alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.app_waf.arn
}

resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "/aws/waf/${var.ecs_cluster_name}"
  retention_in_days = 30
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn           = aws_wafv2_web_acl.app_waf.arn
}