# ==============================================================================
# AWS Enterprise Landing Zone - Platform Identity
# ==============================================================================
# Purpose:
#   Establishes the IAM account-level identity baseline.
#
#   Enterprise workforce identity is managed through IAM Identity Center in:
#       landing-zone/global/iam-baseline
#
#   This module provides account-level IAM controls that complement
#   IAM Identity Center.
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
# IAM ACCOUNT PASSWORD POLICY
# ==============================================================================

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_symbols                = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  allow_users_to_change_password = true
}

# ==============================================================================
# OUTPUT
# ==============================================================================

output "identity_status" {
  description = "Status of the IAM identity baseline"
  value       = "IAM account identity baseline applied successfully."
}

