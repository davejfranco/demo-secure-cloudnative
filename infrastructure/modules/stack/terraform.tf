terraform {
  # Minimum required version
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "dr"
  region = var.dr_aws_region
}

