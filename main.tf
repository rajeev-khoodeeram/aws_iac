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
# ADDED AFTER IMPORTING THE DIFFERENT ACOUNTS
# =============================================================================
provider "aws" {
  alias  = "security"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::918441610185:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "log_archive"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::218979539610:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "network"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::474340841503:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "retail_prod"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::967172220355:role/OrganizationAccountAccessRole"
  }
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

  // We specify the provider alias for the networking module to ensure that it uses the correct AWS account (network shared services account) for creating networking resources.
  providers = {
    aws = aws.network
  }
}

# 3. Centralized Logging & Audit Trails (CloudTrail, S3)
module "logging" {
  source     = "./landing-zone/platform/logging"
  aws_region = var.aws_region

  // We specify the provider alias for the logging module to ensure that it uses the correct AWS account (log archive account) for creating logging resources.
  providers = {
    aws = aws.log_archive
  }
}

# 4. Security Baselines (GuardDuty, Security Hub, KMS)
module "security" {
  source     = "./landing-zone/platform/security"
  aws_region = var.aws_region

  // We specify the provider alias for the security module to ensure that it uses the correct AWS account (security account) for creating security resources.
  providers = {
    aws = aws.security
  }
}

# 5. Shared Services (Container Registries, Bastions, DNS)
module "shared_services" {
  source     = "./landing-zone/platform/shared-services"
  aws_region = var.aws_region

  // We specify the provider alias for the shared services module to ensure that it uses the correct AWS account (network shared services account) for creating shared services resources.
  providers = {
    aws = aws.network
  }
}


# ==============================================================================
# ACCOUNTS 
# ==============================================================================


module "accounts" {
  source = "./landing-zone/global/accounts"

  workloads_ou_id     = module.organizations.workloads_ou_id
  core_platform_ou_id = module.organizations.core_platform_ou_id
  security_ou_id      = module.organizations.security_compliance_ou_id

  security_account_email               = var.security_account_email
  log_archive_account_email            = var.log_archive_account_email
  network_sharedservices_account_email = var.network_sharedservices_account_email
  retail_prod_account_email            = var.retail_prod_account_email
}



# ==============================================================================
# IAM Identity Center
# ==============================================================================

// Have been commented - will be bootstrapped after the accounts have been created and the IAM baseline module has been applied to each of the accounts. This is because IAM Identity Center requires the account IDs of the AWS accounts that were created in the accounts module, and those account IDs are not available until after the accounts module has completed successfully.

# module "iam_baseline" {
#   source = "./landing-zone/global/iam-baseline"

#   # IAM Identity Center assigns permissions to existing AWS accounts. So we retrieve each of them from accounts module and pass them to the IAM baseline module.
#   security_account_id        = module.accounts.security_account_id
#   log_archive_account_id     = module.accounts.log_archive_account_id
#   network_sharedservices_account_id = module.accounts.network_sharedservices_account_id
#   # shared_services_account_id = module.accounts.shared_services_account_id
#   retail_prod_account_id     = module.accounts.retail_prod_account_id
#   # retail_nonprod_account_id  = module.accounts.retail_nonprod_account_id


#   # We add a dependency on the accounts module to ensure that the IAM baseline module is only applied after the accounts module has completed successfully. This is important because the IAM baseline module needs to know the account IDs of the AWS accounts that were created in the accounts module.
#   depends_on = [
#     module.accounts
#   ]
# }