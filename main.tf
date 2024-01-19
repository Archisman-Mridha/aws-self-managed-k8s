terraform {
  required_version = ">= 1.4.6"

  required_providers {

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }

  }
}

provider "aws" {
  access_key = var.args.credentials.access_key
  secret_key = var.args.credentials.secret_key

  region = var.args.region

  default_tags {
    tags = {
      project = var.args.project_name
    }
  }
}
