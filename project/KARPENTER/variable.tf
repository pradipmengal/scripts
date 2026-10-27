variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}

variable "sqs_queue_name" {
  description = "Karpenter interruption SQS queue name"
  type        = string
  default     = "karpenter-interruption"
}

