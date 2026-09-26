# ==============================================================================
# AWS Enterprise Landing Zone - Platform Networking
# ==============================================================================
# Purpose:
#   Creates the core enterprise network foundation in the Bank-Network account.
#
#   This module is responsible for:
#     - Core enterprise VPC
#     - Multi-AZ public subnets
#     - Multi-AZ private subnets
#     - Multi-AZ database subnets
#     - NAT Gateways
#     - VPC DNS support
#
#   Future additions:
#     - Transit Gateway
#     - TGW route tables
#     - VPC attachments
#     - Site-to-Site VPN
#     - Hybrid / SD-WAN connectivity
#
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ==============================================================================
# CORE ENTERPRISE VPC
# ==============================================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  # --------------------------------------------------------------------------
  # VPC
  # --------------------------------------------------------------------------

  name = "vpc-bank-core-prod"
  cidr = var.vpc_cidr

  # --------------------------------------------------------------------------
  # Availability Zones
  # --------------------------------------------------------------------------

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  # --------------------------------------------------------------------------
  # Public Subnets
  # --------------------------------------------------------------------------

  public_subnets = [
    "10.100.101.0/24",
    "10.100.102.0/24",
    "10.100.103.0/24"
  ]

  # --------------------------------------------------------------------------
  # Private Application / Compute Subnets
  # --------------------------------------------------------------------------

  private_subnets = [
    "10.100.0.0/20",
    "10.100.16.0/20",
    "10.100.32.0/20"
  ]

  # --------------------------------------------------------------------------
  # Database Subnets
  # --------------------------------------------------------------------------

  database_subnets = [
    "10.100.150.0/24",
    "10.100.151.0/24",
    "10.100.152.0/24"
  ]

  # --------------------------------------------------------------------------
  # NAT Gateway
  # --------------------------------------------------------------------------
  # Production uses one NAT Gateway per AZ for high availability.
  #
  # Private workloads can therefore reach approved external AWS services
  # or the Internet without being directly exposed through public IPs.
  # --------------------------------------------------------------------------

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # --------------------------------------------------------------------------
  # DNS
  # --------------------------------------------------------------------------

  enable_dns_hostnames = true
  enable_dns_support   = true

  # --------------------------------------------------------------------------
  # Database Subnet Group
  # --------------------------------------------------------------------------

  create_database_subnet_group = true

  # --------------------------------------------------------------------------
  # Enterprise Tags
  # --------------------------------------------------------------------------

  tags = {
    Environment = "Production"
    Purpose     = "Core-Banking-Networking"
    Compliance  = "PCI-DSS"
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "vpc_id" {
  description = "ID of the core enterprise VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the core enterprise VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "database_subnets" {
  description = "Database subnet IDs"
  value       = module.vpc.database_subnets
}

output "availability_zones" {
  description = "Availability Zones used by the enterprise VPC"
  value       = module.vpc.azs
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

