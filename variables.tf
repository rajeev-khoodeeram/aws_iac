variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

# ------------------------------------------------------------------------------
# AWS Organizations Account Emails
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