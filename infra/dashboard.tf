resource "aws_cloudwatch_dashboard" "wishifai" {
  dashboard_name = "wishifai-${var.candidate_number}"
  dashboard_body = <<DASHBOARD
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${local.metrics_namespace}",
            "wishifai.gift.suggestions.count"
          ]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "${var.aws_region}",
        "title": "Analyserte bilder (pr. 5 min)"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "${local.metrics_namespace}",
            "wishifai.gift.suggestions.avg"
          ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "${var.aws_region}",
        "title": "Gjennomsnitt gaveforslag pr. analyse"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "CPUUtilization",
            "ClusterName", "${var.ecs_cluster_name}",
            "ServiceName", "${aws_ecs_express_gateway_service.wishifai.service_name}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.aws_region}",
        "title": "CPU-bruk (%)",
        "yAxis": { "left": { "min": 0, "max": 100 } },
        "annotations": {
          "horizontal": [ { "label": "Autoskalering (60 %)", "value": 60 } ]
        }
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 6,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "MemoryUtilization",
            "ClusterName", "${var.ecs_cluster_name}",
            "ServiceName", "${aws_ecs_express_gateway_service.wishifai.service_name}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.aws_region}",
        "title": "Minnebruk (%)",
        "yAxis": { "left": { "min": 0, "max": 100 } }
      }
    },
    {
      "type": "metric",
      "x": 16,
      "y": 6,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ECS",
            "LiveTaskCount",
            "ClusterName", "${var.ecs_cluster_name}",
            "ServiceName", "${aws_ecs_express_gateway_service.wishifai.service_name}"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "${var.aws_region}",
        "title": "Kjørende tasks",
        "yAxis": { "left": { "min": 0, "max": 3 } }
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 12,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [ { "id": "used", "label": "Heap brukt", "expression": "SUM(SEARCH('{${local.metrics_namespace},area,id} MetricName=\"jvm.memory.used.value\" area=\"heap\"', 'Average', 60))" } ],
          [ { "id": "max",  "label": "Heap maks",  "expression": "SUM(SEARCH('{${local.metrics_namespace},area,id} MetricName=\"jvm.memory.max.value\" area=\"heap\"', 'Average', 60))" } ]
        ],
        "region": "${var.aws_region}",
        "title": "JVM heap (bytes)",
        "yAxis": { "left": { "min": 0 } }
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 12,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [ { "id": "latency", "expression": "SEARCH('{${local.metrics_namespace},error,exception,method,outcome,status,uri} MetricName=\"http.server.requests.avg\" uri=\"/api/analyze\"', 'Average', 60)" } ]
        ],
        "region": "${var.aws_region}",
        "title": "HTTP-latens /api/analyze (ms)",
        "yAxis": { "left": { "min": 0 } }
      }
    },
    {
      "type": "metric",
      "x": 16,
      "y": 12,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [ { "id": "gc", "label": "GC-tid", "expression": "SUM(SEARCH('{${local.metrics_namespace},action,cause,gc} MetricName=\"jvm.gc.pause.sum\"', 'Sum', 60))" } ]
        ],
        "region": "${var.aws_region}",
        "title": "GC-tid pr. minutt (ms)",
        "yAxis": { "left": { "min": 0 } }
      }
    }
  ]
}
DASHBOARD
}