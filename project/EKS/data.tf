data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "apurv-demo-tfstate-dev2"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  public_subnet_ids  = values(data.terraform_remote_state.vpc.outputs.public_subnets)
  private_subnet_ids = values(data.terraform_remote_state.vpc.outputs.private_subnets)
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
}

