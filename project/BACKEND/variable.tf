variable "project" {
  description = "Project name to tag resources"
  type        = string
  default     = "demo-project2"
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Unique name for S3 bucket"
  type        = string
  default     = "apurv-demo-tfstate-dev2"
}

