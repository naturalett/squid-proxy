variable "name" {
  description = "Base name for all resources"
  default     = "squid-proxy-ns"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN"
  default     = ""
  type        = string
}

variable "env" {
  description = "The environment of the infrastructure"
  default     = "prod"
  type        = string
}

variable "account_id" {
  description = "The Account ID"
  default     = ""
  type        = string
}
