variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.170.0.0/16"
}

variable "azs" {
  description = "List of AZs"
  type        = list(string)
  default     = ["us-east-1c", "us-east-1d"]
}

variable "public_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.170.0.0/20", "10.170.16.0/20"]
}

variable "private_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.170.128.0/20", "10.170.144.0/20"]
}

