# ==============================================================================
# AWS Enterprise Landing Zone - Accounts Module Outputs
# ==============================================================================

output "security_account_id" {
  description = "AWS account ID for the Security account"
  value       = aws_organizations_account.security.id
}

output "log_archive_account_id" {
  description = "AWS account ID for the Log Archive account"
  value       = aws_organizations_account.log_archive.id
}

output "network_account_id" {
  description = "AWS account ID for the Network account"
  value       = aws_organizations_account.network.id
}

output "shared_services_account_id" {
  description = "AWS account ID for the Shared Services account"
  value       = aws_organizations_account.shared_services.id
}

output "retail_prod_account_id" {
  description = "AWS account ID for the Retail Banking Production account"
  value       = aws_organizations_account.retail_prod.id
}

output "retail_nonprod_account_id" {
  description = "AWS account ID for the Retail Banking Non-Production account"
  value       = aws_organizations_account.retail_nonprod.id
}