# Remote state data source to fetch outputs from VPC module
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "apurv-demo-tfstate-dev2" # same bucket as VPC
    key    = "vpc/terraform.tfstate"   # path to vpc state
    region = "us-east-1"
  }
}

# Convenience locals
locals {
  vpc_id        = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet = data.terraform_remote_state.vpc.outputs.public_subnets
  private_rt    = data.terraform_remote_state.vpc.outputs.private_route_tables
}

