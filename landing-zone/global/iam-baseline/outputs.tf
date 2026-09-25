# ==============================================================================
# IAM Identity Center Outputs
# ==============================================================================

output "sso_instance_arn" {
  description = "IAM Identity Center instance ARN"
  value       = local.sso_instance_arn
}

output "platform_admin_permission_set_arn" {
  description = "Platform Administrator permission set ARN"
  value       = aws_ssoadmin_permission_set.platform_admin.arn
}

output "security_audit_permission_set_arn" {
  description = "Security Audit permission set ARN"
  value       = aws_ssoadmin_permission_set.security_audit.arn
}

output "read_only_permission_set_arn" {
  description = "Read Only permission set ARN"
  value       = aws_ssoadmin_permission_set.read_only.arn
}