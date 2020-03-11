terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "amtrust-tf-state"
    key    = "pipelines/landing-zone/terraform.tfstate"
    region = "us-east-1"
  }
}
#-----------------------------------------------
# Set up proviers 
#-----------------------------------------------
provider "aws" {
  region = "us-east-1"
}
