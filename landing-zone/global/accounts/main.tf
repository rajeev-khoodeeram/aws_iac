resource "aws_organizations_account" "security" {
 //name      = "Bank-Security"
  name       = "ryansec"
  email     = var.security_account_email
  parent_id = var.security_ou_id

  close_on_deletion = false

  lifecycle {
  prevent_destroy = true
}
}

resource "aws_organizations_account" "log_archive" {
  //name      = "Bank-Log-Archive"
  name              = "ryanlog"
  email     = var.log_archive_account_email
  parent_id = var.security_ou_id

  close_on_deletion = false

  lifecycle {
  prevent_destroy = true
}
}

resource "aws_organizations_account" "network_sharedservices" {
  //name      = "Bank-Network-Shared-Services"
  name              = "rajeevoutlook"
  email     = var.network_sharedservices_account_email
  parent_id = var.core_platform_ou_id

  close_on_deletion = false

  lifecycle {
  prevent_destroy = true
}
}

# resource "aws_organizations_account" "shared_services" {
#   name      = "Bank-Shared-Services"
#   email     = var.shared_services_account_email
#   parent_id = var.core_platform_ou_id

#   close_on_deletion = false
# }

resource "aws_organizations_account" "retail_prod" {
  //name      = "Retail-Banking-Production"
  name              = "RetailProd"
  email     = var.retail_prod_account_email
  parent_id = var.workloads_ou_id

  close_on_deletion = false

  lifecycle {
  prevent_destroy = true
}
}

# resource "aws_organizations_account" "retail_nonprod" {
#   name      = "Retail-Banking-NonProduction"
#   email     = var.retail_nonprod_account_email
#   parent_id = var.workloads_ou_id

#   close_on_deletion = false
# }