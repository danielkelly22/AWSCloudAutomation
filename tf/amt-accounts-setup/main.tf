terraform {
  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust"

    workspaces {
      name = "amt-accounts-setup"
    }
  }
}

provider "aws" {
  version = "~> 3.38.0"
} # master
