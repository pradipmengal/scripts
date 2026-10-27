terraform {
  backend "s3" {
    bucket         = "apurv-demo-tfstate-dev2"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "demo-project2-tf-locks"
    encrypt        = true
  }

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
