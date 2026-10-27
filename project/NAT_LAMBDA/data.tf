data "terraform_remote_state" "nat" {
  backend = "s3"
  config = {
    bucket = "apurv-demo-tfstate-dev2" # replace
    key    = "nat/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  nat_asg_names = data.terraform_remote_state.nat.outputs.nat_asg_names
  nat_eni_ids   = data.terraform_remote_state.nat.outputs.nat_eni_ids
}
