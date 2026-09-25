resource "aws_organizations_account" "security" {
  name      = "Bank-Security"
  email     = var.security_account_email
  parent_id = var.security_ou_id

  close_on_deletion = false
}

resource "aws_organizations_account" "log_archive" {
  name      = "Bank-Log-Archive"
  email     = var.log_archive_account_email
  parent_id = var.security_ou_id

  close_on_deletion = false
}

resource "aws_organizations_account" "network" {
  name      = "Bank-Network"
  email     = var.network_account_email
  parent_id = var.core_platform_ou_id

  close_on_deletion = false
}

resource "aws_organizations_account" "shared_services" {
  name      = "Bank-Shared-Services"
  email     = var.shared_services_account_email
  parent_id = var.core_platform_ou_id

  close_on_deletion = false
}

resource "aws_organizations_account" "retail_prod" {
  name      = "Retail-Banking-Production"
  email     = var.retail_prod_account_email
  parent_id = var.workloads_ou_id

  close_on_deletion = false
}

resource "aws_organizations_account" "retail_nonprod" {
  name      = "Retail-Banking-NonProduction"
  email     = var.retail_nonprod_account_email
  parent_id = var.workloads_ou_id

  close_on_deletion = false
}