variable "project_name" {
  description = "Project name"
  type        = string
  default     = "niraxo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "niraxo"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "postgresadmin"
}

