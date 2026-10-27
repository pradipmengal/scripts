terraform {
  backend "s3" {
    bucket         = "apurv-demo-tfstate-dev1"
    key            = "route53/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "demo-project-tf-locks"
    encrypt        = true
  }
}

