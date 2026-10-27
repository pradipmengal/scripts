terraform {
  backend "s3" {
    bucket         = "apurv-demo-tfstate-dev2"
    key            = "nat_lambda/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "demo-project2-tf-locks"
    encrypt        = true
  }
}
