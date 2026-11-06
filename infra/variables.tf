variable "aws_region" {
  description = "AWS-region tjenesten kjører i"
  type        = string
  default     = "eu-west-1"
}

variable "candidate_number" {
  description = "Kandidatnummer, brukes som suffiks på ressursnavn"
  type        = string
  default     = "8"
}

variable "image_tag" {
  description = "Tag på container-imaget i ECR"
  type        = string
  default     = "latest"
}

variable "ecr_repository" {
  description = "Navn på ECR-repoet for image"
  type        = string
  default     = "kandidat-8"
}

variable "execution_role_arn" {
  description = "henter image fra ECR, skriver logger"
  type        = string
  default     = "arn:aws:iam::244530008913:role/ecsTaskExecutionRole"
}

variable "infrastructure_role_arn" {
  description = "Infrastructure role for ECS Express"
  type        = string
  default     = "arn:aws:iam::244530008913:role/service-role/ecsInfrastructureRoleForExpressServices"
}

variable "ecs_cluster_name" {
  description = "ECS-clusteret Express-tjenesten kjører i"
  type        = string
  default     = "default"
}