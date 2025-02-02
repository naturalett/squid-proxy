variable "name" {
  description = "The base name for all resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for TLS"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS Task execution"
  type        = string
}

variable "environment" {
  description = "The environment of the infrastructure"
  type        = string
}
