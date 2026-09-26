# ==============================================================================
# AWS Enterprise Landing Zone - Accounts Module Variables
# ==============================================================================

variable "security_ou_id" {
  description = "OU ID for Security and Compliance accounts"
  type        = string
}

variable "core_platform_ou_id" {
  description = "OU ID for Core Platform accounts"
  type        = string
}

variable "workloads_ou_id" {
  description = "OU ID for Workload accounts"
  type        = string
}

# ------------------------------------------------------------------------------
# AWS Account Email Addresses
# ------------------------------------------------------------------------------

variable "security_account_email" {
  description = "Email address for the Security AWS account"
  type        = string
}

variable "log_archive_account_email" {
  description = "Email address for the Log Archive AWS account"
  type        = string
}

variable "network_sharedservices_account_email" {
  description = "Email address for the Network AWS account"
  type        = string
}

# variable "shared_services_account_email" {
#   description = "Email address for the Shared Services AWS account"
#   type        = string
# }

variable "retail_prod_account_email" {
  description = "Email address for the Retail Banking Production AWS account"
  type        = string
}

# commented since I am not able to create more than 5 AWS accounts in my free tier, so I will use the same email for both retail accounts
# variable "retail_nonprod_account_email" {
#   description = "Email address for the Retail Banking Non-Production AWS account"
#   type        = string
# }