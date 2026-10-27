data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "apurv-demo-tfstate-dev"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "apurv-demo-tfstate-dev"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  private_subnet_ids = values(data.terraform_remote_state.vpc.outputs.private_subnets)
}

