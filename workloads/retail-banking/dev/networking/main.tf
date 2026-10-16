terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::967172220355:role/OrganizationAccountAccessRole"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-retail-dev"
  cidr = var.vpc_cidr

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]

  public_subnets = [
    "10.110.101.0/24",
    "10.110.102.0/24"
  ]

  private_subnets = [
    "10.110.1.0/24",
    "10.110.2.0/24"
  ]

  database_subnets = [
    "10.110.151.0/24",
    "10.110.152.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true # to reduce cost in dev environment (normally we can have more than 1)

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group = true

  tags = {
    Environment = "Dev"
    Application = "RetailBanking"
    ManagedBy   = "Terraform"
  }
}