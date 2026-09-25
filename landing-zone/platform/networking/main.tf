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
  region = "us-east-1"
}

# Core Enterprise VPC Foundation
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-bank-core-prod"
  cidr = "10.100.0.0/16"

  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets   = ["10.100.101.0/24", "10.100.102.0/24", "10.100.103.0/24"]
  private_subnets  = ["10.100.0.0/20", "10.100.16.0/20", "10.100.32.0/20"] # Large blocks for EKS pod IPs
  database_subnets = ["10.100.150.0/24", "10.100.151.0/24", "10.100.152.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false # High availability: 1 NAT Gateway per AZ for production
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group = true

  tags = {
    Environment = "Production"
    Purpose     = "Core-Banking-Networking"
    Compliance  = "PCI-DSS"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}