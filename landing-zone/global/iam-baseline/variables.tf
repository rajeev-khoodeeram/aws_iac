# ==============================================================================
# IAM Identity Center Variables
# ==============================================================================

variable "security_account_id" {
  description = "AWS account ID for the Security account"
  type        = string
}

variable "log_archive_account_id" {
  description = "AWS account ID for the Log Archive account"
  type        = string
}

variable "network_account_id" {
  description = "AWS account ID for the Network account"
  type        = string
}

variable "shared_services_account_id" {
  description = "AWS account ID for the Shared Services account"
  type        = string
}

variable "retail_prod_account_id" {
  description = "AWS account ID for the Retail Banking Production account"
  type        = string
}

variable "retail_nonprod_account_id" {
  description = "AWS account ID for the Retail Banking Non-Production account"
  type        = string
}