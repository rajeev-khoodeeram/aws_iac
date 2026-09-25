# ==============================================================================
# AWS Enterprise Landing Zone - Root Orchestrator
# ==============================================================================
# Description: This root-level Terraform configuration orchestrates the entire
#              multi-account AWS enterprise landing zone. It ties together core
#              governance, identity, multi-AZ networking, centralized logging,
#              security baselines, and shared services modules to mirror your
#              parallel Azure cloud architecture.
# Author:      Rajeev Khoodeeram
# Date:        September 24, 2026
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

provider "aws" {
  region = var.aws_region
}



# ==============================================================================
# GLOBAL GOVERNANCE
# ==============================================================================
module "organizations" {
  source = "./landing-zone/global/organizations"
}

module "scp" {
  source                    = "./landing-zone/global/scp"
  workloads_ou_id           = module.organizations.workloads_ou_id
  core_platform_ou_id       = module.organizations.core_platform_ou_id
  security_compliance_ou_id = module.organizations.security_compliance_ou_id
}



# ==============================================================================
# CORE PLATFORM
# ==============================================================================


# 1. Identity & Access Management Baseline
module "identity" {
  source = "./landing-zone/platform/identity"
}

# 2. Core Networking (VPC, Subnets, Gateways)
module "networking" {
  source     = "./landing-zone/platform/networking"
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


# ==============================================================================
# ACCOUNTS 
# ==============================================================================


module "accounts" {
  source = "./landing-zone/global/accounts"

  workloads_ou_id     = module.organizations.workloads_ou_id
  core_platform_ou_id = module.organizations.core_platform_ou_id
  security_ou_id      = module.organizations.security_compliance_ou_id


  # We are passing the email addresses for each account to the accounts module. These emails are used to create the AWS accounts in the landing zone.
  # The email addresses are defined in terraform.tfvars and passed as variables to the accounts module.
  security_account_email        = var.security_account_email
  log_archive_account_email     = var.log_archive_account_email
  network_account_email         = var.network_account_email
  shared_services_account_email = var.shared_services_account_email
  retail_prod_account_email     = var.retail_prod_account_email
  retail_nonprod_account_email  = var.retail_nonprod_account_email
}



# ==============================================================================
# IAM Identity Center
# ==============================================================================

module "iam_baseline" {
  source = "./landing-zone/global/iam-baseline"

  # IAM Identity Center assigns permissions to existing AWS accounts. So we retrieve each of them from accounts module and pass them to the IAM baseline module.
  security_account_id        = module.accounts.security_account_id
  log_archive_account_id     = module.accounts.log_archive_account_id
  network_account_id         = module.accounts.network_account_id
  shared_services_account_id = module.accounts.shared_services_account_id
  retail_prod_account_id     = module.accounts.retail_prod_account_id
  retail_nonprod_account_id  = module.accounts.retail_nonprod_account_id


  # We add a dependency on the accounts module to ensure that the IAM baseline module is only applied after the accounts module has completed successfully. This is important because the IAM baseline module needs to know the account IDs of the AWS accounts that were created in the accounts module.
  depends_on = [
    module.accounts
  ]
}