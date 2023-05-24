terraform {
  backend "s3" {
    bucket="wordcount-tfstate"
    key = "wordcount-app.tfstate"
    region = "eu-west-1"
    encrypt= true
    dynamodb_table = "wordcount-tf-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3.0"
    }
  }

  required_version = "~> 1.4"
}

provider "aws" {
  region = var.aws_region
}

locals {
  prefix = var.prefix
  common_tags = {
    ApplicationName = var.ApplicationName
    VPCname         = var.VPCname
  }
}
resource "random_pet" "lambda_bucket_name" {
  prefix = "contacts-sf"
  length = 4
}

