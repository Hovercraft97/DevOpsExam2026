resource "aws_ecs_express_gateway_service" "wishifai" {
  service_name            = "wishifai-${var.candidate_number}"
  execution_role_arn      = var.execution_role_arn
  infrastructure_role_arn = var.infrastructure_role_arn
  task_role_arn           = aws_iam_role.task_role.arn

  cpu               = "512"
  memory            = "1024"
  health_check_path = "/api/health"

  primary_container {
    image          = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository}:${var.image_tag}"
    container_port = 8080

    environment {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.images.bucket
    }

    environment {
      name  = "METRICS_NAMESPACE"
      value = local.metrics_namespace
    }
  }

  scaling_target {
    min_task_count            = 1
    max_task_count            = 2
    auto_scaling_metric       = "AVERAGE_CPU"
    auto_scaling_target_value = 60
  }

  wait_for_steady_state = true

  depends_on = [aws_iam_role_policy.task_permissions]
}