terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.45"
      configuration_aliases = [aws.region2]
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}
