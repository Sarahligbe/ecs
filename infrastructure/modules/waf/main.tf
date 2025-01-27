resource "aws_wafv2_web_acl" "app_waf" {
  name        = "${var.ecs_cluster_name}-waf"
  description = "WAF for ECS application"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # First Layer: CAPTCHA Challenge for Moderate Traffic
  rule {
    name     = "CaptchaRule"
    priority = 1

    action {
      captcha {}
    }

    statement {
      rate_based_statement {
        limit              = var.captcha_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CaptchaMetric"
      sampled_requests_enabled   = true
    }
  }

  # Second Layer: Block Excessive Traffic
  rule {
    name     = "BlockRule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.ecs_cluster_name}WAFMetrics"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "app_waf_alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.app_waf.arn
}

resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "aws-waf-logs-${var.ecs_cluster_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_resource_policy" "waf_logging" {
  policy_name     = "webacl-policy-${var.ecs_cluster_name}"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "delivery.logs.amazonaws.com"
      }
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.waf_log_group.arn}:*"
    }]
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn           = aws_wafv2_web_acl.app_waf.arn

  depends_on = [aws_cloudwatch_log_resource_policy.waf_logging]
}