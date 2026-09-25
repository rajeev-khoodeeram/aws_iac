output "core_platform_ou_id" {
  value = aws_organizations_organizational_unit.core.id
}

output "workloads_ou_id" {
  value = aws_organizations_organizational_unit.workloads.id
}

output "security_compliance_ou_id" {
  value = aws_organizations_organizational_unit.security.id
}

output "organization_id" {
  value = aws_organizations_organization.bank_org.id
}