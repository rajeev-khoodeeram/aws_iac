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
}

# 1. Identity & Access Management Baseline
module "identity" {
  source = "./landing-zone/platform/identity"
}

# 2. Core Networking (VPC, Subnets, Gateways)
module "networking" {
  source    = "./landing-zone/platform/networking"
  aws_region = var.aws_region
  vpc_cidr   = var.vpc_cidr
}

# 3. Centralized Logging & Audit Trails (CloudTrail, S3)
module "logging" {
  source     = "./landing-zone/platform/logging"
  aws_region = var.aws_region
}

# 4. Security Baselines (GuardDuty, Security Hub, KMS)
module "security" {
  source     = "./landing-zone/platform/security"
  aws_region = var.aws_region
}

# 5. Shared Services (Container Registries, Bastions, DNS)
module "shared_services" {
  source     = "./landing-zone/platform/shared-services"
  aws_region = var.aws_region
}