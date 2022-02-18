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
  profile = "production"
}
