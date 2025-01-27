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
  name              = "/aws/waf/${var.ecs_cluster_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "waf_logging" {
  name = "waf_logging"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "waf.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "waf_logging" {
  name = "waf_logging"
  role = aws_iam_role.waf_logging.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.waf_log_group.arn}:*"
    }
  ]
}
EOF
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.app_waf.arn
}