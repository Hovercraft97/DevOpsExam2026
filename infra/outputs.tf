output "service_url" {
  description = "Offentlig URL til Wishifai"
  value       = "${aws_ecs_express_gateway_service.wishifai.ingress_paths[0].endpoint}"
}

output "s3_bucket_name" {
  description = "Bucket bildene lastes opp til"
  value       = aws_s3_bucket.images.bucket
}

output "task_role_arn" {
  description = "Task-rollen containeren kjører med"
  value       = aws_iam_role.task_role.arn
}

output "image_uri" {
  description = "Imaget som kjører i tjenesten"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository}:${var.image_tag}"
}