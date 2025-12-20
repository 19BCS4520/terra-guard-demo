terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

}
# 1. Primary Region (Default) -> us-east-1  
provider "aws" {
  region = "us-east-1"
}
# 2. Secondary Region (Disaster Recovery) -> us-west-1
# EXPLANATION: The 'alias' meta-argument creates a second provider configuration.
# We reference this later using 'provider = aws.dr_west' to put resources in California.
provider "aws" {
  alias  = "dr_west"
  region = "us-east-1"
}