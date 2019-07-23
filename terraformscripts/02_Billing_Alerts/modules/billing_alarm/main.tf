resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name                = "Billing Alert - Estimated Bill Exceeds ${var.monthly_billing_threshold}$"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "EstimatedCharges"
  namespace                 = "AWS/Billing"
  period                    = "21600"
  statistic                 = "Maximum"
  threshold                 = "${var.monthly_billing_threshold}"
  alarm_actions             = ["${var.sns_topic_arn}"]

  dimensions = {
      Currency = "${var.currency}"
  }
}