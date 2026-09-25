# ==============================================================================
# AWS Enterprise Landing Zone - IAM Identity Center
# ==============================================================================

data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

# ------------------------------------------------------------------------------
# Platform Administrator
# ------------------------------------------------------------------------------

resource "aws_ssoadmin_permission_set" "platform_admin" {
  instance_arn = local.sso_instance_arn
  name         = "PlatformAdmin"
  description  = "Full administrative access for AWS platform administrators"
}

resource "aws_ssoadmin_managed_policy_attachment" "platform_admin" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.platform_admin.arn

  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ------------------------------------------------------------------------------
# Security Auditor
# ------------------------------------------------------------------------------

resource "aws_ssoadmin_permission_set" "security_audit" {
  instance_arn = local.sso_instance_arn
  name         = "SecurityAudit"
  description  = "Read-only security auditing access"
}

resource "aws_ssoadmin_managed_policy_attachment" "security_audit" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_audit.arn

  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

# ------------------------------------------------------------------------------
# Read Only
# ------------------------------------------------------------------------------

resource "aws_ssoadmin_permission_set" "read_only" {
  instance_arn = local.sso_instance_arn
  name         = "ReadOnly"
  description  = "Read-only access across AWS accounts"
}

resource "aws_ssoadmin_managed_policy_attachment" "read_only" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.read_only.arn

  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}