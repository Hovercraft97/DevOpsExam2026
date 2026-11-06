resource "aws_cloudwatch_metric_alarm" "bedrock_latency" {
  alarm_name        = "wishifai-${var.candidate_number}-bedrock-latency-high"
  alarm_description = "Gjennomsnittlig svartid for Bedrock er over ${var.bedrock_latency_threshold_ms} ms i 3 av 5 minutter. Brukerne venter for lenge på gaveforslag."

  namespace   = local.metrics_namespace
  metric_name = "wishifai.bedrock.duration.avg"
  statistic   = "Average"
  period      = 60

  evaluation_periods  = 5
  datapoints_to_alarm = 3
  threshold           = var.bedrock_latency_threshold_ms
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}