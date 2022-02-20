terraform {
  required_version = "1.1.6"
  backend "remote" {
    organization="ozsh_dev_env"

    workspaces {
      name = "aisknet_workspace"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
module "prd" {
  source = "../../"
  github_token = var.github_token
}
