terraform {
  backend "s3" {
    bucket         = "apurv-demo-tfstate-dev1"
    key            = "karpenter/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "demo-project-tf-locks"
    encrypt        = true
  }
}


