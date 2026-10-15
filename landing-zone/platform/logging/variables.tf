# ==============================================================================
# AWS Enterprise Landing Zone - Platform Logging Variables
# ==============================================================================

variable "aws_region" {
  description = "AWS region where the centralized logging infrastructure is deployed"
  type        = string
}


variable "management_account_id" {
  description = "AWS Organizations management account ID"
  type        = string
}

variable "organization_id" {
  description = "AWS Organizations organization ID"
  type        = string
}